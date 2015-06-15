module Router
  module Subroute
    class Definition
      attr_reader :path, :controller, :action, :name,
                  :request_methods, :defaults

      def initialize(controller, path, options = {})
        options.assert_valid_keys(:to, :via, :as, :defaults)

        @controller = controller

        @path = path.to_s
        @request_methods = Array(options[:via]).map(&:to_s)
        validate_request_methods!
        if main? && request_methods.include?('get')
          fail 'Primary route cannot be redefined'
        end

        @action = options[:to]
        @name = options[:as].try(:to_sym)

        @defaults = (options[:defaults] || {}).with_indifferent_access
      end

      def main?
        path.blank?
      end

      def match(path, request_method)
        match_path(path) if via?(request_method)
      end

      def path_parameter_names
        Pattern.build(path).names
      end

      def via?(request_method)
        request_methods.include?(request_method.to_s.downcase)
      end

      def interpolate(params)
        params = params.reverse_merge(defaults)
        Pattern.build(path).build_formatter.evaluate(params)
      end

      private

      def match_path(path)
        pattern_string = '*path'
        pattern_string << "/#{self.path}" if self.path.present?
        pattern_string << '(.:format)'
        Pattern.extract_params(path, pattern_string)
      end

      def validate_request_methods!
        return if request_methods.any?
        fail ArgumentError, 'No request method defined'
      end
    end
  end
end
