module Router
  module ErrorHandler
    autoload :Configuration, 'router/error_handler/configuration'
    autoload :Middleware, 'router/error_handler/middleware'
    autoload :Utils, 'router/error_handler/utils'

    module_function

    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end
  end
end
