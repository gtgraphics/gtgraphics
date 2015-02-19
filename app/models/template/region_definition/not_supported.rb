class Template < ActiveRecord::Base
  class RegionDefinition < ActiveRecord::Base
    class NotSupported < StandardError
      attr_reader :template

      def initialize(template)
        @template = template
        super "Template does not support regions: #{@template.inspect}"
      end
    end
  end
end
