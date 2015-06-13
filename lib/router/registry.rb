module Router
  class Registry
    attr_reader :routes

    def initialize(routes)
      @routes = routes
    end

    def match(path, options = {})
      @routes << Route.new(path, options)
    end

    %i(get post patch put delete head).each do |accept_method|
      define_method(accept_method) do |path, options = {}|
        match(path, options.merge(via: accept_method))
      end
    end
  end
end
