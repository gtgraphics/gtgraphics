module Router
  class Route
    attr_reader :path, :controller, :action, :name, :request_methods, :pattern

    def initialize(controller, path, options = {})
      @controller = controller

      @path = path.to_s
      fail ArgumentError, 'No route path defined' if @path.blank?
      @request_methods = Array(options[:via]).map(&:to_s)
      validate_request_methods!

      @action = (options[:to] || path).to_s
      @name = options[:as]

      pattern_string = "*path/#{self.path}"
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        @pattern = pattern_class.from_string(pattern_string)
      else
        @pattern = pattern_class.new(pattern_string)
      end
    end

    def match(path, request_method)
      match_path(path) if via?(request_method)
    end

    def via?(request_method)
      request_methods.include?(request_method.to_s.downcase)
    end

    def interpolate(params = {})
      pattern
      binding.pry
    end

    private

    def match_path(path)
      match = pattern.match(path)
      match.names.zip(match.captures).to_h if match
    end

    def validate_request_methods!
      return if request_methods.any?
      fail ArgumentError, 'No request method defined'
    end
  end
end
