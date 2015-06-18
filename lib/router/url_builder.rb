module Router
  ##
  # Builds the path consisting of a page path and optional subroute and
  # query parameters.
  class UrlBuilder
    PROTOCOL_SUFFIX = '://'

    attr_reader :controller, :path, :locale, :format, :params, :subroute_name,
                :protocol

    ##
    # Initializes the {UrlBuilder}.
    #
    # @param [ActionController::Base] controller The controller context that
    #   is needed to fetch the subroute and request information from.
    # @param [Page, String] page_or_path Either the page which is going to be
    #   referenced or a custom path.
    # @param [Symbol, String, nil] subroute_name The name of the subroute that
    #   has been registered in the controller.
    # @param [Hash] options A mixed Hash of parameters and options.
    # @option options [Symbol, String, nil] :locale The locale printed out in
    #   the path. Uses the I18n.locale when omitted. Does not print out a
    #   locale in the resulting path when set to nil.
    # @option options [Boolean] :only_path Prepends the protocol, host and port
    #   to the generated URL if set to false.
    # @option options [Symbol, String] :protocol The protocol that is used when
    #   the :only_path option is false.
    def initialize(controller, page_or_path, *args)
      options = args.extract_options!.with_indifferent_access
      @controller = controller
      @path = page_or_path.try(:path).try(:to_s) || page_or_path.to_s
      @subroute_name = args.first.try(:to_sym)
      @locale = options.fetch(:locale) { I18n.locale }.try(:to_s)
      @format = options[:format]
      @only_path = options.fetch(:only_path, true)
      @protocol = options.fetch(:protocol) { controller.request.protocol }.to_s
      unless @protocol.ends_with?(PROTOCOL_SUFFIX)
        @protocol = "#{@protocol}#{PROTOCOL_SUFFIX}"
      end
      @params = options.except(:locale, :format, :only_path, :protocol)
    end

    def host_with_port
      controller.request.host_with_port
    end

    def only_path?
      @only_path
    end

    def subroute
      return nil if subroute_name.nil?
      @subroute ||= controller.class.subroutes.find do |sr|
        sr.name == subroute_name
      end
      @subroute || fail(UrlGenerationError, 'Sub route not found: ' \
                                            ":#{subroute_name} " \
                                            "(in #{controller.class.name})")
    end

    def path_parameters
      return ActiveSupport::HashWithIndifferentAccess.new if subroute.nil?
      params.slice(*subroute.parameter_names)
    end

    def query_parameters
      params.except(*path_parameters.keys)
    end

    def query_string
      "?#{query_parameters.to_query}" if query_parameters.any?
    end

    def default_format?
      format.to_s.downcase == Path::DEFAULT_FORMAT
    end

    def to_s
      prefix = "#{protocol}#{host_with_port}" unless only_path?
      path_segments = []
      path_segments << locale if locale.present?
      path_segments << path if path.present?
      path_segments << subroute.interpolate(path_parameters) if subroute
      format_string = ".#{format}" if format.present? && !default_format?
      "#{prefix}/#{File.join(path_segments)}#{format_string}#{query_string}"
    end
  end
end
