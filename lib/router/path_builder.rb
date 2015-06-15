module Router
  class PathBuilder
    attr_reader :controller, :path, :locale, :format, :params, :subroute

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
      @params = options.except(:locale, :format).with_indifferent_access

      subroute_name = args.first.try(:to_sym)
      return if subroute_name.nil?
      @subroute = controller.class.registered_routes.find do |subroute|
        subroute.name == subroute_name
      end
      fail ArgumentError, "Sub route not found: :#{subroute_name} " \
        "(in #{controller.class.name})" if @subroute.nil?
    end

    def path_parameters
      return {} if subroute.nil?
      params.slice(*subroute.path_parameter_names)
    end

    def query_parameters
      params.except(*path_parameters.keys)
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
      path_segments << subroute.interpolate(path_parameters) if subroute
      format_string = ".#{format}" if format.present? && !default_format?
      "/#{File.join(path_segments)}#{format_string}#{query_string}"
    end
  end
end
