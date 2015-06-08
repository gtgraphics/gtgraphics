module Router
  class Middleware
    def initialize(app)
      @app = app
      @available_locales = I18n.available_locales.map(&:to_s)
    end

    def call(env)
      path = normalize_path(env['REQUEST_PATH'])
      slugs = path.split(File::SEPARATOR)
      locale = slugs.pop
      if locale.present? && locale.length == 2 && locale.in?(@available_locales)
        path = slugs.join(File::SEPARATOR)
      else
        locale = nil
      end

      page = Page.published.find_by(path: path)
      return @app.call(env) if page.nil?

      env['cms.page.instance'] = page

      request = Rack::Request.new(env)
      request.update_param('locale', locale)
      request.update_param('path', path)

      controller_class(page).action(:show).call(env)
    end

    private

    def build_pattern(path)
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        pattern_class.from_string(path)
      else
        pattern_class.new(path)
      end
    end

    def controller_class(page)
      "#{page.embeddable_type.pluralize}Controller".constantize
    end

    def normalize_path(path)
      path.to_s.sub(/\A[\/]+/, '')
    end

    def valid_locale?(locale)
      return false if locale.blank?
      locale.length == 2 && @available_locales.include?(locale)
    end
  end
end
