module Router
  module Subroute
    class Definition
      attr_reader :path, :pattern, :controller, :action, :name,
                  :request_methods, :defaults

      def initialize(controller, path, options = {})
        options.assert_valid_keys(:to, :via, :as, :defaults)

        @controller = controller

        @path = Path.normalize(path)
        @request_methods = Array(options[:via]).map { |rm| rm.to_s.downcase }
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

      def match(path, request_method)
        return nil unless via?(request_method)
        return { path: path }.with_indifferent_access if root?
        pattern_string = '(*path/)'
        pattern_string << "#{self.path}" if self.path.present?
        match = Path.build_pattern(pattern_string).match(path)
        match.names.zip(match.captures).to_h.with_indifferent_access if match
      end

      def via?(request_method)
        request_methods.include?(request_method.to_s.downcase)
      end

      def interpolate(params)
        Path.build_pattern(path).build_formatter
          .evaluate(params.reverse_merge(defaults))
      end
    end
  end
end
