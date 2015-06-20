module Router
  module ErrorHandler
    class Middleware
      def call(env)
        parser = Router::Parser.from_env(env)
        prepare_request(env, parser)

        exception = env['action_dispatch.exception']
        fail 'No exception caught' if exception.nil?

        status_code = ErrorHandler.config.handlers[exception.class.name]
        status_code ||= Utils::DEFAULT_STATUS_CODE
        env['error.status_code'] = status_code

        status_name = Utils.status_symbol(status_code)
        ErrorsController.action(status_name).call(env)
      end

      private

      def prepare_request(env, parser)
        params = parser.path_parameters.dup
        params[:locale] = parser.locale
        params[:path] = parser.path

        request = ActionDispatch::Request.new(env)
        request.params.merge!(params)
        request.path_parameters.merge!(params)
        request
      end
    end
  end
end
