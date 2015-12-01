module SlashBuster
  class Middleware
    SLASH = '/'

    def initialize(app)
      @app = app
    end

    def call(env)
      Rewriter.call(@app, env)
    end
  end
end
