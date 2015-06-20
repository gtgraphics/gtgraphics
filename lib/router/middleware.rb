module Router
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      parser = Parser.from_env(env)
      return @app.call(env) if parser.invalid_request?

      env['cms.page'] = parser.page
      env['cms.subroute'] = parser.subroute
      prepare_request(env, parser)

      parser.controller.action(parser.action).call(env)
    end

    private

    def prepare_request(env, parser)
      params = parser.path_parameters.merge(locale: parser.locale)

      request = ActionDispatch::Request.new(env)
      request.params.merge!(params)
      request.params[:controller] = parser.controller.controller_name
      request.params[:action] = parser.action.to_s
      request.path_parameters.merge!(params)

      request
    end
  end
end
