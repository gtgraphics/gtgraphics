class Page < ActiveRecord::Base
  module Templatable
    extend ActiveSupport::Concern

    included do
      has_many :regions, class_name: 'Page::Region', dependent: :destroy, inverse_of: :page

      delegate :name, to: :template, prefix: true, allow_nil: true
    end

    def available_templates
      template_class.try(:all) || Template.none
    end

    def check_template_support!
      raise Template::NotSupported.new(self) unless support_templates?
    end

    def support_templates?
      embeddable_class.try(:support_templates?) || false
    end

    def template_class
      embeddable.class.template_class if support_templates?
    end

    def template
      check_template_support!
      embeddable.try(:template)
    end

    def template=(template)
      check_template_support!
      embeddable.try(:template=, template)
    end

    def template_id
      check_template_support!
      embeddable.try(:template_id)
    end

    def template_id=(template_id)
      check_template_support!
      embeddable.try(:template_id=, template_id)
    end
  end
end
