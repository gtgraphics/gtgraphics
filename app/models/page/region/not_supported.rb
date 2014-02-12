class Page < ActiveRecord::Base
  class Region < ActiveRecord::Base
    class NotSupported < Exception
      attr_reader :page
      
      def initialize(page)
        @page = page
        super "Page does not support regions: #{@page.inspect}"
      end
    end
  end
end