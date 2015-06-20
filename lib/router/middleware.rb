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
      request = ActionDispatch::Request.new(env)
      request.params.merge!(parser.path_parameters)
      request.params[:locale] = parser.locale
      request.params[:format] = parser.format
      request.path_parameters.merge!(parser.path_parameters)
      request.path_parameters[:locale] = parser.locale
      request
    end
  end
end
