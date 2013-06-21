module Sluggable
  extend ActiveSupport::Concern

  included do
    cattr_accessor :slug_options
  end

  class << self
    def sanitize_slug(slug)
      slug.try(:parameterize)
    end
  end

  module ClassMethods
    def acts_as_sluggable(options = {})
      field = options.fetch(:field, :slug)
      class_variable_set("@@slug_options", { destination_attribute: field })
      validates field, presence: true
      validates field, uniqueness: true if options[:unique]
      before_validation :sanitize_slug
    end

    def acts_as_sluggable_on(attribute, options = {})
      field = options.fetch(:field, :slug)
      class_variable_set("@@slug_options", { source_attribute: attribute, destination_attribute: field })
      validates field, presence: true
      validates field, uniqueness: true if options[:unique]
      before_validation :set_slug
      before_validation :sanitize_slug
    end
  end

  private
  def set_slug
    if send(slug_options[:destination_attribute]).blank?
      source_attribute = slug_options[:source_attribute]
      source_attribute_value = case source_attribute
      when Proc then source_attribute.call(self)
      when Symbol then send(source_attribute)
      else raise ArgumentError, 'source attribute must be a Proc or Symbol'
      end
      send("#{slug_options[:destination_attribute]}=", source_attribute_value)
    end
  end

  def sanitize_slug
    destination_attribute_value = send(slug_options[:destination_attribute])
    if destination_attribute_value.present?
      send("#{slug_options[:destination_attribute]}=", Sluggable.sanitize_slug(destination_attribute_value))
    end
  end
end