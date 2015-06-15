module Router
  class PathBuilder
    attr_reader :controller, :path, :locale, :format, :params, :route

    def initialize(controller, *args)
      @controller = controller

      options = args.extract_options!
      @path = extract_path(args.first)
      @locale = options.fetch(:locale) { I18n.locale }.try(:to_s)
      @format = options[:format]
      @params = options.except(:locale, :format, :route_name, :protocol)

      route_name = options[:route_name].try(:to_sym)
      @route = controller.class.registered_routes.find do |route|
        route.name == route_name
      end
    end

    def path_parameters
      params # TODO
    end

    def query_parameters
      params # TODO
    end

    def query_string
      "?#{query_parameters.to_query}" if query_parameters.any?
    end

    def default_format?
      format.to_s == 'html'
    end

    def to_s
      path_segments = []
      path_segments << locale if locale.present?
      path_segments << path
      path_segments << route.interpolate(path_parameters) if route
      format_string = ".#{format}" if format.present? && !default_format?
      "/#{File.join(path_segments)}#{format_string}#{query_string}"
    end

    private

    def extract_path(page_or_path)
      if page_or_path.nil?
        page = controller.env['cms.page.instance']
        fail ArgumentError, 'Current page not set' if page.nil?
        page.path.to_s
      elsif page_or_path.respond_to?(:path)
        page_or_path.path.to_s
      else
        page_or_path.to_s
      end
    end
  end
end
