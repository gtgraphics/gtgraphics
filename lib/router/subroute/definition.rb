module Router
  module Subroute
    class Definition
      attr_reader :path, :controller, :action, :name, :request_methods

      def initialize(controller, path, options = {})
        @controller = controller

        @path = path.to_s
        @request_methods = Array(options[:via]).map(&:to_s)
        validate_request_methods!

        @action = (options[:to] || path).to_s
        @name = options[:as]
      end

      def match(path, request_method)
        match_path(path) if via?(request_method)
      end

      def via?(request_method)
        request_methods.include?(request_method.to_s.downcase)
      end

      def interpolate(params = {})
        build_pattern(path).build_formatter.evaluate(params)
      end

      private

      def match_path(path)
        pattern_string = '*path'
        pattern_string << "/#{self.path}" if self.path.present?
        match = build_pattern(pattern_string).match(path)
        match.names.zip(match.captures).to_h if match
      end

      def build_pattern(pattern_string)
        pattern_class = ActionDispatch::Journey::Path::Pattern
        if pattern_class.respond_to?(:from_string)
          pattern_class.from_string(pattern_string)
        else
          pattern_class.new(pattern_string)
        end
      end

      def validate_request_methods!
        return if request_methods.any?
        fail ArgumentError, 'No request method defined'
      end
    end
  end
end
