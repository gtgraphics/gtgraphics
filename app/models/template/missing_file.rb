class Template < ActiveRecord::Base
  class MissingFile < Exception
    attr_reader :template

    def initialize(template)
      @template = template
      super "Missing template file for #{template.inspect}"
    end
  end
end