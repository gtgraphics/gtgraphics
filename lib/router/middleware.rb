module Router
  class Middleware
    include ActiveSupport::Benchmarkable

    DEFAULT_FORMAT = 'html'

    def initialize(app)
      @app = app
      @available_locales = I18n.available_locales.map(&:to_s)
    end

    def call(env)
      parser = Parser.new(env['REQUEST_PATH'], env['REQUEST_METHOD'])
      return @app.call(env) if parser.page.nil?

      env['cms.page'] = parser.page
      env['cms.subroute'] = parser.subroute

      request = Rack::Request.new(env)
      request.update_param('locale', parser.locale)
      request.update_param('path', parser.path)
      request.update_param('subpath', parser.subpath)
      parser.path_parameters.each do |key, value|
        request.update_param(key, value)
      end

      binding.pry

      # if page
      #   env['cms.page.instance'] = page
      #   env['cms.page.route'] = route_name
      #   request.update_param('locale', locale)
      #   request.update_param('path', page.path)
      #   path_params.each do |key, value|
      #     request.update_param(key, value)
      #   end
      # end


      # route_params = parse_request_path(env['REQUEST_PATH'])
      # locale, path, format = route_params.values_at(:locale, :path, :format)

      # page = find_page(path, env['REQUEST_METHOD'])
      # return @app.call(env) if page.nil?

      # binding.pry

      # page, route_name, action, path_params =
      #   find_page(path, env['REQUEST_METHOD'])
      # if page
      #   env['cms.page.instance'] = page
      #   env['cms.page.route'] = route_name
      #   request.update_param('locale', locale)
      #   request.update_param('path', page.path)
      #   path_params.each do |key, value|
      #     request.update_param(key, value)
      #   end
      # end

      # return @app.call(env) if page.nil?

      # controller_class = controller_class_from_page_type(page.embeddable_type)
      # request.update_param('controller', controller_class.controller_name)
      # request.update_param('action', action)
      # request.update_param('format', format)

      # controller_class.action(action.to_sym).call(env)
    end

    private

    def find_page(path, request_method)
      # Find out the used subroute
      matching_subroutes = {}
      Page::EMBEDDABLE_TYPES.each do |page_type|
        controller_class = "#{page_type.pluralize}Controller".safe_constantize
        next if controller_class.nil?
        result = nil
        controller_class.subroutes.each do |subroute|
          params = subroute.match(path, request_method)
          next if params.nil?
          subpath = Path.normalize(path.sub(/\A#{Regexp.escape(params[:path].to_s)}/, ''))
          result = { definition: subroute, path: params[:path],
                     subpath: subpath, params: params.except(:path) }
          break
        end
        matching_subroutes[page_type] = result if result
      end

      # Lookup actual page
      conditions = []

      base_condition = Page.arel_table[:path].eq(path)
      base_condition = base_condition.and(
        Page.arel_table[:embeddable_type].not_in(matching_subroutes.keys)
      ) if matching_subroutes.any?

      conditions << base_condition
      conditions += matching_subroutes.collect do |page_type, subroute|
        Page.arel_table[:path].eq(subroute[:path])
        .and(Page.arel_table[:embeddable_type].eq(page_type))
      end

      page = Page.find_by(conditions.reduce(:or))
      subroute = matching_subroutes[page.embeddable_type]
      binding.pry
      page
    end

    def find_bla(path, request_method)
      matched_subroutes = matched_subroutes_by_page_type(path, request_method)

      page = find_page(path, matched_subroutes)
      return nil if page.nil?

      matched_subroute = matched_subroutes[page.embeddable_type]
      path_params = matched_subroute.params

      definition = matched_subroute[:definition]
      if definition
        action = definition.action
        action ||= page.template.filename if page.support_templates?
        action ||= definition.path
        route_name = definition.name
      elsif request_method.downcase == 'get'
        action = page.template.filename if page.support_templates?
      else
        page = nil
      end

      if action.nil? || !controller_class_from_page_type(page.embeddable_type)
                         .action_methods.include?(action)
        action = 'show'
      end

      [page, route_name, action, path_params.with_indifferent_access]
    end

    def logger
      Rails.logger
    end

    # Path Parsing

    def parse_request_path(path)
      slugs = Path.normalize(path).split(File::SEPARATOR)
      locale = slugs.shift
      if valid_locale?(locale)
        path = slugs.join(File::SEPARATOR)
      else
        locale = nil
      end
      format = extract_format!(path)
      { locale: locale, path: path, format: format }
    end

    def valid_locale?(locale)
      return false if locale.blank?
      locale.length == 2 && @available_locales.include?(locale)
    end

    def extract_format!(path)
      format = path.match(/\.(.*)\z/).try(:captures).try(:first)
      path.sub!(/\.#{Regexp.escape(format)}\z/, '') if format
      format || DEFAULT_FORMAT
    end
  end
end
