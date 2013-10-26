module Templatable
  extend ActiveSupport::Concern

  module ClassMethods
    def template_type
      @template_type
    end

    def template_type=(type)
      @template_type = type.to_s
    end

    def template_class
      @template_class ||= template_type.try(:constantize)
    end
  end
end