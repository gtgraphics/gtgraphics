class Page < ActiveRecord::Base
  class MissingTemplate < Exception
    attr_reader :page

    def initialize(page)
      @page = page
      super "Missing template for #{page.embeddable_type} in #{page.inspect}"
    end
  end
end