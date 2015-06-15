module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_routes, instance_accessor: false
      self.registered_routes = []

      helper_method :root_path, :root_url, :page_path, :page_url
    end

    module ClassMethods
      def routes(&block)
        self.registered_routes = registered_routes.dup
        Registry.new(self).instance_exec(&block)
      end
    end

    private

    def root_path(options = {})
      page_path(Page.root, options)
    end

    def root_url(options = {})
      page_path(Page.root, options)
    end

    def page_path(*args)
      PathBuilder.new(self, *args).to_s
    end

    def page_url(*args)
      "#{request.protocol}#{request.host_with_port}" + page_path(*args)
    end

    # TODO: Put route path helpers here
  end
end
