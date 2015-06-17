module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :subroutes, instance_accessor: false
      self.subroutes = []

      helper_method :current_page, :current_subroute,
                    :root_path, :root_url, :page_path, :page_url,
                    :current_page_path, :current_page_url
    end

    module ClassMethods
      def routes(&block)
        self.subroutes = subroutes.dup
        Subroute::Registry.new(self).instance_exec(&block)
      end
    end

    protected

    def current_page
      env['cms.page']
    end

    def current_subroute
      env['cms.subroute']
    end

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
      options = args.extract_options!
      subroute = args.shift || current_subroute.try(:name)
      page_path(current_page, subroute, *args, options)
    end

    def current_page_url(*args)
      options = args.extract_options!
      subroute = args.shift || current_subroute.try(:name)
      page_url(current_page, subroute, *args, options)
    end
  end
end
