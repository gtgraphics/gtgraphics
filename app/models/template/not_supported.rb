class Template < ActiveRecord::Base
  class NotSupported < StandardError
    attr_reader :page
    
    def initialize(page)
      @page = page
      super "Templates are not supported for page type: #{@page.embeddable_type}"
    end
  end
end