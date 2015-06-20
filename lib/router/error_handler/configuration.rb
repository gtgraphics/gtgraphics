module Router
  module ErrorHandler
    class Configuration
      def initialize
        reset!
      end

      attr_reader :handlers

      def rescue_from(*errors)
        options = errors.extract_options!
        errors.flatten.each do |error_class|
          handlers[error_class.to_s] = Utils.status_code(options.fetch(:with))
        end
      end

      def reset!
        @handlers = {}
      end
    end
  end
end
