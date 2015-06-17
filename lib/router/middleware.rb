module Router
  class Middleware
    DEFAULT_FORMAT = 'html'

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
      request = Rack::Request.new(env)
      request.update_param('locale', parser.locale)
      request.update_param('path', parser.path)
      request.update_param('subpath', parser.subpath)
      parser.path_parameters.each do |key, value|
        request.update_param(key, value)
      end
    end

    def method_not_allowed_response(allowed_request_methods)
      allowed = Array(allowed_request_methods).map { |m| m.to_s.upcase } * ', '
      [405, { 'Allow' => allowed }, []]
    end
  end
end
