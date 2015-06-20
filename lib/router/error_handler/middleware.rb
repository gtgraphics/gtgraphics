module Router
  module ErrorHandler
    class Middleware
      def call(env)
        parser = Router::Parser.from_env(env)

        exception = env['action_dispatch.exception']
        fail 'No exception caught' if exception.nil?

        status_code = ErrorHandler.config.handlers[exception.class.name]
        status_code ||= Utils::DEFAULT_STATUS_CODE
        env['error.status_code'] = status_code
        status_name = Utils.status_symbol(status_code)

        prepare_request(env, parser, status_name)

        ErrorsController.action(status_name).call(env)
      end

      private

      def prepare_request(env, parser, status_name)
        params = parser.path_parameters.merge(locale: parser.locale)

        request = ActionDispatch::Request.new(env)
        request.params.merge!(params)
        request.params[:controller] = 'errors'
        request.params[:action] = status_name.to_s
        request.path_parameters.merge!(params)
        request
      end
    end
  end
end
