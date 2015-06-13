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
    end
  end
end
