class SlashBuster
  SLASH = '/'

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if %w(GET HEAD).exclude?(env['REQUEST_METHOD'])

    uri = URI.parse(env['REQUEST_URI'])
    return @app.call(env) unless uri.path.end_with?(SLASH)

    uri.path = uri.path.sub(/#{Regexp.escape(SLASH)}+\z/, '')

    Rails.logger.info "Busting slashes and redirecting to: #{uri.to_s}"

    [301, { 'Location' => uri.to_s }, []]
  end
end
