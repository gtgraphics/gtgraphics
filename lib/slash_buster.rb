class SlashBuster
  SLASH = '/'

  def initialize(app)
    @app = app
  end

  def call(env)
    uri = URI.parse(env['REQUEST_URI'])
    return @app.call(env) unless uri.path.end_with?(SLASH)
    uri.path = uri.path.sub(/#{Regexp.escape(SLASH)}+\z/, '')
    [301, { 'Location' => uri.to_s }, []]
  end
end
