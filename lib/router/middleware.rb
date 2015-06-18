module Router
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      parser = Parser.new(env['REQUEST_PATH'], env['REQUEST_METHOD'])
      return @app.call(env) if parser.invalid_request?

      env['cms.page'] = parser.page
      env['cms.subroute'] = parser.subroute
      prepare_request(env, parser)

      parser.controller.action(parser.action).call(env)
    end

    private

    def prepare_request(env, parser)
      params = parser.path_parameters.dup
      params[:locale] = parser.locale
      params[:path] = parser.path
      params[:subpath] = parser.subpath

      request = ActionDispatch::Request.new(env)
      request.params.merge!(params)
      request.path_parameters.merge!(params)
    end
  end
end
