class Template < ActiveRecord::Base
  class RegionDefinition < ActiveRecord::Base
    class NotFound < StandardError
      attr_reader :name, :template
      
      def initialize(name, template)
        @name = name
        @template = template
        super "Region :#{@name} has not been defined for #{@template.inspect}"
      end
    end
  end
end