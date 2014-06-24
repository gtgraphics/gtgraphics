class Template < ActiveRecord::Base
  class NotSupported < StandardError
    attr_reader :page
    
    def initialize(page)
      @page = page
      super "Page does not support templates: #{@page.inspect}"
    end
  end
end