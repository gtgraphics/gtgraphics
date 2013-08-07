# Usage:
#
#   include Sluggable
#
#   slug :title
#   slug :title, to: :permalink
#   slug :title, unique: false
#   slug :title, force: true
#   slug :title, scope: [:category_id, :parent_id]
#

module Sluggable
  extend ActiveSupport::Concern

  DEFAULTS = {
    to: :slug,
    unique: true,
    force: false
  }

  included do
    cattr_reader :slug_source_column, :slug_column, :slug_options
  end
 
  module ClassMethods
    def slugs(attribute, options = {})
      raise 'slug attribute already defined' unless class_variable_get("@@slug_source_column").nil?

      options = DEFAULTS.merge(options)

      class_variable_set("@@slug_source_column", attribute.to_sym)
      class_variable_set("@@slug_column", options.fetch(:to).to_sym)
      class_variable_set("@@slug_options", options)

      before_save :generate_slug

      if options[:unique] and !options[:force]
        validates slug_column, uniqueness: options.slice(:scope), allow_blank: true
      end
    end
  end
 
  def to_param
    self.send(self.class.slug_column)
  end
 
  private
  def generate_unique_slug
    scope_conditions = Array(self.class.slug_options[:scope]).map { |scope_column| [scope_column, send(scope_column)] }

    association_scope = self.class
    association_scope = association_scope.where.not(id: self.id) if persisted? # exclude self from uniqueness check
    association_scope = association_scope.where(scope_conditions) if scope_conditions.any?

    while association_scope.exists?(self.class.slug_column => self.send(self.class.slug_column))
      if self.send(self.class.slug_column) =~ /\-[0-9]+\z/
        # increments numeric slug suffix until slug is unique within its scope
        self.send("#{self.class.slug_column}=", self.send(self.class.slug_column).next)
      else
        # appends numeric suffix to slug (starting with 2)
        self.send("#{self.class.slug_column}=", "#{destination_value}-2")
      end
    end
  end

  def generate_slug
    options = self.class.slug_options

    source_value = self.send(self.class.slug_source_column)
    destination_value = self.send(self.class.slug_column)

    if source_value.present?
      slug = destination_value.present? ? destination_value.parameterize : source_value.parameterize
      self.send("#{self.class.slug_column}=", slug)
      generate_unique_slug if options[:force] and options[:unique]
    end
  end
end