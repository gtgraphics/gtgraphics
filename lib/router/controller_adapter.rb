module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_routes, instance_accessor: false
      self.registered_routes = []
    end

    module ClassMethods
      def routes(&block)
        self.registered_routes = registered_routes.dup
        Registry.new(self).instance_exec(&block)
      end
    end

    # TODO: Put route path helpers here
  end
end
