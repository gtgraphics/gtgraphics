module Router
  class Registry
    def initialize(controller)
      @controller = controller
      @routes = @controller.registered_routes
    end

    def match(path, options = {})
      @routes << Route.new(@controller, path, options)
    end

    %i(get post patch put delete head).each do |accept_method|
      define_method(accept_method) do |path, options = {}|
        match(path, options.merge(via: accept_method))
      end
    end
  end
end
