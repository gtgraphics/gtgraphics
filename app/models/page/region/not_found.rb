class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    class NotFound < Exception
      attr_reader :name, :template
      
      def initialize(name, template)
        @name = name
        @template = template
        super "Region :#{@name} has not been defined for #{@template.inspect}"
      end
    end
  end
end