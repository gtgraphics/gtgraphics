module Sluggable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_slug(attribute_name = :slug)
      composed_of attribute_name, class_name: 'Slug', mapping: [attribute_name, 'to_s'], allow_nil: true, converter: :generate
    end
  end
end