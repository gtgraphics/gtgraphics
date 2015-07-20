module Router
  module ControllerAdapter
    extend ActiveSupport::Concern

    included do
      class_attribute :subroutes, instance_accessor: false
      self.subroutes = []

      helper_method :current_page, :current_subroute,
                    :root_path, :root_url, :page_path, :page_url,
                    :current_page_path, :current_page_url, :change_locale_path

      include UrlHelpers
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
      url_params = request.path_parameters.merge(request.query_parameters)
                   .merge(locale: locale)
      current_page_path(url_params)
    end
  end
end
