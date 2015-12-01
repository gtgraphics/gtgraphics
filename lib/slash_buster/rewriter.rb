module SlashBuster
  ##
  # A class responsible for checking whether rewriting for the
  # requested URL is necessary.
  #
  # @attr_reader [#call] app
  # @attr_reader [Hash] env
  # @attr_reader [Rack::Request] request
  class Rewriter
    SLASH = '/'

    attr_reader :app, :env, :request, :uri

    ##
    # @param [#call] app
    # @param [Hash] env
    def initialize(app, env)
      @app = app
      @env = env
      @request = Rack::Request.new(env)
      @uri = URI.parse(request.url)
    end

    ##
    # @param [#call] app
    # @param [Hash] env
    # @return [Array] Rack response being forwarded to Rack by the middleware.
    def self.call(app, env)
      new(app, env).call
    end

    ##
    # @return [Array] Rack response being forwarded to Rack by the middleware.
    def call
      return cascade unless valid_request?
      new_uri = sanitize_path
      return redirect(new_uri) if uri.path != new_uri.path
      cascade
    end

    private

    def cascade
      app.call(env)
    end

    def redirect(uri)
      Rails.logger.info "Busted slashes and redirected: #{uri}"
      [301, { 'Location' => uri.to_s }, []]
    end

    def sanitize_path
      new_uri = uri.dup
      path = new_uri.path.gsub(/#{Regexp.escape(SLASH)}{2,}/, SLASH)
      path.gsub!(/#{Regexp.escape(SLASH)}+\z/, '')
      new_uri.path = path
      new_uri
    end

    def valid_request?
      !root? && (request.get? || request.head?)
    end

    def root?
      request.path == SLASH
    end
  end
end
