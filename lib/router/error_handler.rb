module Router
  module ErrorHandler
    module_function

    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end
  end
end
