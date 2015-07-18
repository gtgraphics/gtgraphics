module Router
  module ErrorHandler
    class Middleware
      def call(env)
        exception = env['action_dispatch.exception']
        fail 'No exception caught' if exception.nil?

        status_code = ErrorHandler.config.handlers[exception.class.name]
        status_code ||= Utils::DEFAULT_STATUS_CODE
        env['error.status_code'] = status_code
        status_name = Utils.status_symbol(status_code)

        parser = Router::Parser.new(env['action_dispatch.original_path'],
                                    env['REQUEST_METHOD'])
        request = ActionDispatch::Request.new(env)
        request.params[:locale] = parser.locale
        request.params[:format] = parser.format
        request.path_parameters[:locale] = parser.locale

        ErrorsController.action(status_name).call(env)
      end
    end
  end
end
