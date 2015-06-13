module Router
  class Middleware
    def initialize(app)
      @app = app
      @available_locales = I18n.available_locales.map(&:to_s)
    end

    def call(env)
      path = normalize_path(env['REQUEST_PATH'])
      slugs = path.split(File::SEPARATOR)
      locale = slugs.pop
      if valid_locale?(locale)
        path = slugs.join(File::SEPARATOR)
      else
        locale = nil
      end

      # TODO: How to find a page if a subroute has been defined? Such as:
      # /wallpapers/image-name/buy

      # 1st go through all the additional routes and look if the path can be
      # parsed

      matched_routes = {}
      additional_routes_by_controller.each do |controller, routes|
        match = nil
        matched_route = nil
        routes.each do |route|
          pattern = build_pattern("*path/#{route.path}")
          match = pattern.match(path)
          if match
            matched_route = route
            break
          end
        end
        next if match.nil?
        path_params = match.names.zip(match.captures).to_h
        matched_routes[controller] ||= []
        matched_routes[controller] << MatchedRoute.new(matched_route, path_params)
      end

      binding.pry if matched_routes.any?

      page = Page.find_by(path: path)
      return @app.call(env) if page.nil?

      env['cms.page.instance'] = page

      request = Rack::Request.new(env)
      request.update_param('locale', locale)
      request.update_param('path', path)

      controller_class = "#{page.embeddable_type.pluralize}Controller".constantize
      # TODO: Take care for the subroutes defined by the controller
      # If it is no subroute, only accept env['ACCEPT_METHOD'] to be 'GET'
      controller_class.action(:show).call(env)
    end

    private

    def build_pattern(path)
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        pattern_class.from_string(path)
      else
        pattern_class.new(path)
      end
    end

    def controller_classes
      @controller_classes ||=
        Page::EMBEDDABLE_TYPES
        .collect { |name| "#{name.pluralize}Controller".safe_constantize }
        .compact
    end

    def additional_routes_by_controller
      @additional_routes_by_controller ||=
        controller_classes.collect { |c| [c.name, c.registered_routes] }.to_h
    end

    def normalize_path(path)
      path.to_s.sub(/\A[\/]+/, '')
    end

    def valid_locale?(locale)
      return false if locale.blank?
      locale.length == 2 && @available_locales.include?(locale)
    end
  end
end
