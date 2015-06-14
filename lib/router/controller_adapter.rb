module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_routes
      self.registered_routes = []
    end

    module ClassMethods
      def routes(&block)
        self.registered_routes = registered_routes.dup
        registry = Router::Registry.new(registered_routes)
        registry.instance_exec(&block)
      end
    end
  end
end
