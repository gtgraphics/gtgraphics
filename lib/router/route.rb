module Router
  class Route
    attr_reader :path, :controller, :action, :name, :request_methods

    def initialize(controller, path, options = {})
      @controller = controller
      @path = path.to_s
      fail ArgumentError, 'No route path defined' if @path.blank?
      @action = (options[:to] || path).to_s
      @name = options[:as]
      @request_methods = Array(options[:via]).map(&:to_s)
      validate_request_methods!
    end

    def match(path, request_method)
      match_path(path) if via?(request_method)
    end

    def via?(request_method)
      request_methods.include?(request_method.to_s.downcase)
    end

    private

    def match_path(path)
      pattern = build_pattern("*path/#{self.path}")
      match = pattern.match(path)
      match.names.zip(match.captures).to_h if match
    end

    def build_pattern(path)
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        pattern_class.from_string(path)
      else
        pattern_class.new(path)
      end
    end

    def validate_request_methods!
      return if request_methods.any?
      fail ArgumentError, 'No request method defined'
    end
  end
end
