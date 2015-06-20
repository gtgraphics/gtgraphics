module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :subroutes, instance_accessor: false
      self.subroutes = []

      helper_method :current_page, :current_subroute,
                    :root_path, :root_url, :page_path, :page_url,
                    :current_page_path, :current_page_url, :change_locale_path
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
      options = args.extract_options!.merge(only_path: true)
      page_url(*args, options)
    end

    def page_url(*args)
      UrlBuilder.new(self, *args).to_s
    end

    def current_page_path(*args)
      options = args.extract_options!
      subroute = args.shift || current_subroute.try(:name)
      page_path(current_page, subroute, *args, options)
    end

    def current_page_url(*args)
      options = args.extract_options!.merge(only_path: true)
      current_page_path(current_page, *args, options)
    end

    def change_locale_path(locale)
      parameters = params.except(:controller, :action).merge(locale: locale)
      current_page_path(parameters)
    end
  end
end
