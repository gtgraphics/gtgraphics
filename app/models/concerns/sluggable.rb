module Sluggable
  extend ActiveSupport::Concern

  included do
    cattr_accessor :slug_options
  end

  module ClassMethods
    def acts_as_sluggable_on(attribute, options = {})
      class_variable_set("@@slug_options", { source_attribute: attribute, destination_attribute: options[:field] })
      validates field, presence: true, uniqueness: true
      before_validation :set_slug
    end
  end

  private
  def set_slug
    source_attribute_value = send(slug_options[:source_attribute])
    if send(slug_options[:destination_attribute].blank? and source_attribute_value.present?)
      send("#{slug_options[:destination_attribute]}=", source_attribute_value.parameterize)
    end
  end
end