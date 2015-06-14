module Router
  class Middleware
    include ActiveSupport::Benchmarkable

    def initialize(app)
      @app = app
      @available_locales = I18n.available_locales.map(&:to_s)
    end

    def call(env)
      page, action = nil
      request = Rack::Request.new(env)
      request_path = normalize_path(env['REQUEST_PATH'])

      benchmark "Find Route: /#{request_path}" do
        path = request_path
        locale, path = extract_locale_from_path(path)

        page, action, path_params = find_page(path, env['REQUEST_METHOD'])
        if page
          env['cms.page.instance'] = page
          request.update_param('locale', locale)
          request.update_param('path', page.path)
          path_params.each do |key, value|
            request.update_param(key, value)
          end
        end
      end

      return @app.call(env) if page.nil?

      controller_class = controller_class_from_page_type(page.embeddable_type)
      request.update_param('controller', controller_class.controller_name)
      request.update_param('action', action)
      controller_class.action(action.to_sym).call(env)
    end

    private

    def find_page(path, request_method)
      matched_routes = matched_routes_by_resource(path, request_method)

      conditions = []

      base_condition = Page.arel_table[:path].eq(path)
      base_condition = base_condition.and(
        Page.arel_table[:embeddable_type].not_in(matched_routes.keys)
      ) if matched_routes.any?

      conditions << base_condition
      conditions += matched_routes.collect do |page_type, matched_route|
        Page.arel_table[:path].eq(matched_route[:path])
        .and(Page.arel_table[:embeddable_type].eq(page_type))
      end

      page = Page.find_by(conditions.reduce(:or))
      return nil if page.nil?

      matched_route = matched_routes[page.embeddable_type] || {}
      path_params = matched_route[:path_params] || {}

      if matched_route[:action]
        action = matched_route[:action]
      else
        action = page.template.filename if page.support_templates?
        if action.nil? || !controller_class_from_page_type(page.embeddable_type)
                           .action_methods.include?(action)
          action = 'show'
        end
      end

      [page, action, path_params.with_indifferent_access]
    end

    def extract_locale_from_path(path)
      slugs = path.split(File::SEPARATOR)
      locale = slugs.shift
      if valid_locale?(locale)
        path = slugs.join(File::SEPARATOR)
      else
        locale = nil
      end
      [locale, path]
    end

    def matched_routes_by_resource(path, request_method)
      Page::EMBEDDABLE_TYPES.each_with_object({}) do |page_type, routes|
        controller_class = controller_class_from_page_type(page_type)
        next if controller_class.nil?
        found_route = nil
        path_params = nil
        controller_class.registered_routes.each do |route|
          path_params = route.match(path, request_method)
          if path_params
            found_route = route
            break
          end
        end
        next if path_params.nil?
        path_params = path_params.with_indifferent_access
        routes[page_type] = { page_type: page_type, path: path_params[:path],
                              action: found_route.action,
                              path_params: path_params.except(:path) }
      end
    end

    def normalize_path(path)
      path.to_s.sub(%r{\A[/]+}, '')
    end

    def valid_locale?(locale)
      return false if locale.blank?
      locale.length == 2 && @available_locales.include?(locale)
    end

    def controller_class_from_page_type(page_type)
      "#{page_type.pluralize}Controller".safe_constantize
    end

    def logger
      Rails.logger
    end
  end
end
