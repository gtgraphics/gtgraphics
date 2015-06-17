module Router
  module Subroute
    class Definition
      attr_reader :path, :pattern, :controller, :action, :name,
                  :request_methods, :defaults

      def initialize(controller, path, options = {})
        options.assert_valid_keys(:to, :via, :as, :defaults)

        @controller = controller

        @path = Path.normalize(path)
        @request_methods = Array(options[:via]).map { |m| m.to_s.downcase }
        if request_methods.empty?
          fail ArgumentError, 'No request method defined'
        end
        if via?(:get) && root?
          fail ArgumentError, 'Primary route cannot be redefined'
        end

        @action = options[:to]
        @name = options[:as].try(:to_sym)

        @defaults = (options[:defaults] || {}).with_indifferent_access
      end

      def root?
        path.blank?
      end

      def parameter_names
        pattern.names.map(&:to_sym)
      end

      def match(path, request_method)
        return nil unless via?(request_method)
        return { path: path }.with_indifferent_access if root?
        match = pattern.match(path)
        match.names.zip(match.captures).to_h.with_indifferent_access if match
      end

      def via?(request_method)
        request_methods.include?(request_method.to_s.downcase)
      end

      def interpolate(params)
        Path.build_pattern(path).build_formatter
          .evaluate(params.reverse_merge(defaults))
      end

      private

      def pattern
        pattern_string = '(*path/)'
        pattern_string << "#{path}" if path.present?
        Path.build_pattern(pattern_string)
      end
    end
  end
end
