module Router
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      parser = Parser.from_env(env)

      return @app.call(env) if parser.invalid_request?
      if parser.page.nil?
        return [404, {}, []] if parser.root?
        return @app.call(env)
      end
      return @app.call(env) if parser.controller.nil?

      env['cms.page'] = parser.page
      env['cms.subroute'] = parser.subroute

      request = ActionDispatch::Request.new(env)
      request.params.merge!(parser.path_parameters)
      request.params[:locale] = parser.locale
      request.params[:format] = parser.format
      request.path_parameters.merge!(parser.path_parameters)
      request.path_parameters[:locale] = parser.locale

      parser.controller.action(parser.action).call(env)
    end
  end
end
