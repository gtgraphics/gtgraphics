module Router
  class Registry
    class Route
      attr_reader :path, :options

      def initialize(path, options = {})
        @path = path.to_s
        if options[:via].blank?
          fail ArgumentError, 'no :via option for route specified'
        end
        @options = options
      end

      def request_methods
        Array(options[:via]).map(&:to_s)
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
    end
  end
end
