module Router
  class PathBuilder
    attr_reader :controller, :path, :locale, :format, :params, :route

    def initialize(controller, page_or_path, *args)
      @controller = controller

      options = args.extract_options!
      if page_or_path.respond_to?(:path)
        @path = page_or_path.path.to_s
      else
        @path = page_or_path.to_s
      end

      @locale = options.fetch(:locale) { I18n.locale }.try(:to_s)
      @format = options[:format]
      @params = options.except(:locale, :format, :protocol)

      route_name = args.first.try(:to_sym)
      return if route_name.nil?
      @route = controller.class.registered_routes.find do |route|
        route.name == route_name
      end
      fail ArgumentError, "Sub route not found: :#{route_name} " \
        "(in #{controller.class.name})" if @route.nil?
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
      path_segments << path if path.present?
      path_segments << route.interpolate(path_parameters) if route
      format_string = ".#{format}" if format.present? && !default_format?
      "/#{File.join(path_segments)}#{format_string}#{query_string}"
    end
  end
end
