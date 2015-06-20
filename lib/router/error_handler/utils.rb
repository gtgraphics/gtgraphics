module Router
  module ErrorHandler
    module Utils
      DEFAULT_STATUS_CODE = 500
      STATUS_CODE_TO_SYMBOL = Rack::Utils::SYMBOL_TO_STATUS_CODE.invert

      module_function

      def status_code(status)
        Rack::Utils.status_code(status)
      end

      def status_symbol(status)
        STATUS_CODE_TO_SYMBOL[status_code(status)]
      end
    end
  end
end
