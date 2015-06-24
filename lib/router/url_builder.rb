module Router
  ##
  # Builds the path consisting of a page path and optional subroute and
  # query parameters.
  class UrlBuilder
    DEFAULT_PROTOCOL = 'http://'
    PROTOCOL_SUFFIX = '://'

    attr_reader :page, :protocol, :host, :port, :path, :subroute_name,
                :locale, :format, :params

    def self.default_url_options
      Rails.application.config.action_controller.default_url_options || {}
    end

    ##
    # Initializes the {UrlBuilder}.
    #
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
    def initialize(page_or_path, *args)
      options = args.extract_options!.with_indifferent_access
      if page_or_path.is_a?(String)
        @path = Path.normalize(page_or_path)
      else
        @page = page_or_path
        @path = @page.path
      end

      @protocol = options.fetch(:protocol) do
        UrlBuilder.default_url_options[:protocol] || DEFAULT_PROTOCOL
      end.to_s
      @protocol << PROTOCOL_SUFFIX unless @protocol.ends_with?(PROTOCOL_SUFFIX)

      @host = options.fetch(:host) { UrlBuilder.default_url_options[:host] }
      @port = options.fetch(:port) { UrlBuilder.default_url_options[:port] }

      @subroute_name = args.first.try(:to_sym)
      if subroute_name.present? && page.nil?
        fail UrlGenerationError,
             'Unable to use subrouting unless a page is given to URL builder'
      end

      @locale = options.fetch(:locale) { I18n.locale }.try(:to_s)
      @format = options[:format].try(:to_s).try(:downcase)
      @only_path = options.fetch(:only_path, false)

      @params = options.except(:protocol, :host, :port, :locale,
                               :format, :only_path)
    end

    def only_path?
      @only_path
    end

    def subroute
      return nil if controller_class.nil? || subroute_name.nil?
      @subroute ||= controller_class.subroutes.find do |sr|
        sr.name == subroute_name
      end
      @subroute || fail(UrlGenerationError, 'Sub route not found: ' \
                                            ":#{subroute_name} " \
                                            "(in #{controller.class.name})")
    end

    def to_s
      prefix = "#{protocol}#{host_with_port}" if !only_path? && host.present?
      path_segments = []
      path_segments << locale if locale.present?
      path_segments << path if path.present?
      path_segments << subroute.interpolate(path_parameters) if subroute
      "#{prefix}#{File::SEPARATOR}#{File.join(path_segments)}" \
        "#{format_string}#{query_string}"
    end

    def to_uri
      URI.parse(to_s)
    end

    # Protocol

    def protocol_without_suffix
      protocol.sub(/#{Regexp.escape(PROTOCOL_SUFFIX)}\z/, '')
    end

    # Host & Port

    def default_port
      URI.const_get(protocol_without_suffix.upcase).default_port
    end

    def default_port?
      port == default_port
    end

    def port_string
      return '' if port.blank? || default_port?
      ":#{port}"
    end

    def host_with_port
      "#{host}#{port_string}"
    end

    # Format

    def default_format?
      format == Path::DEFAULT_FORMAT
    end

    def format_string
      return '' if format.blank? || default_format?
      ".#{format}"
    end

    # Parameters

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

    private

    def controller_class
      return nil if page.nil?
      "#{page.embeddable_type.to_s.pluralize}Controller".safe_constantize
    end
  end
end
