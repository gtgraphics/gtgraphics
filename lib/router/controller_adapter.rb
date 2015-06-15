module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :registered_routes, instance_accessor: false
      self.registered_routes = []

      helper_method :root_path, :root_url, :page_path, :page_url,
                    :current_page_path, :current_page_url
    end

    module ClassMethods
      def routes(&block)
        self.registered_routes = registered_routes.dup
        Subroute::Registry.new(self).instance_exec(&block)
      end
    end

    private

    def root_path(options = {})
      page_path(nil, options)
    end

    def root_url(options = {})
      page_url(nil, options)
    end

    def page_path(*args)
      PathBuilder.new(self, *args).to_s
    end

    def page_url(*args)
      options = args.extract_options!.dup
      protocol = "#{options.delete(:protocol)}://" if options.key?(:protocol)
      protocol ||= request.protocol
      "#{protocol}#{request.host_with_port}" + page_path(*args, options)
    end

    def current_page_path(*args)
      page_path(env.fetch('cms.page.instance'), env['cms.page.route'], *args)
    end

    def current_page_url(*args)
      page_url(env.fetch('cms.page.instance'), env['cms.page.route'], *args)
    end
  end
end
