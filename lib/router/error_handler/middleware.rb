module Router
  module ErrorHandler
    class Middleware
      def call(env)
        exception = env['action_dispatch.exception']
        fail 'No exception caught' if exception.nil?

        status_code = ErrorHandler.config.handlers[exception.class.name]
        status_code ||= Utils::DEFAULT_STATUS_CODE
        env['error.status_code'] = status_code
        status = Utils.status_symbol(status_code)

        original_env = restore_original_env(env)
        if status == :internal_server_error
          notify_exception(original_env, exception)
        end

        parser = Router::Parser.from_env(original_env)
        request = ActionDispatch::Request.new(original_env)
        request.params[:locale] = parser.locale
        request.params[:format] = parser.format
        request.path_parameters[:locale] = parser.locale

        ErrorsController.action(status).call(original_env)
      end

      private

      def restore_original_env(env)
        original_env = env.dup
        original_env['PATH_INFO'] =
          File::SEPARATOR + env['action_dispatch.original_path'].to_s
        original_env.delete('action_dispatch.original_path')
        original_env
      end

      def notify_exception(env, exception)
        notified = ExceptionNotifier.notify_exception(exception, env: env)
        env['exception_notifier.delivered'] = true if notified
      end
    end
  end
end
