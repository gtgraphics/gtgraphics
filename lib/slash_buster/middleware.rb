module SlashBuster
  ##
  # The middleware which rewrites URLs with unnecessary slashes in it.
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Rewriter.call(@app, env)
    end
  end
end
