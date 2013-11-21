module TagAssignable
  extend ActiveSupport::Concern

  TAG_SEPARATOR = ','

  module ClassMethods
    def acts_as_tag_assignable_on(*association_names)
      association_names.each do |association_name|
        if association = reflect_on_association(association_name.to_sym) and association.collection?
          singular_association_name = association_name.to_s.singularize
          class_eval %{
            def #{singular_association_name}_tags
              @#{singular_association_name}_tags ||= #{singular_association_name}_ids.join(TagAssignable::TAG_SEPARATOR)
            end

            def #{singular_association_name}_tags=(tags)
              ids = tags.split(TagAssignable::TAG_SEPARATOR).map(&:to_i).reject(&:zero?)
              self.#{singular_association_name}_ids = ids
              @#{singular_association_name}_tags = ids.join(TagAssignable::TAG_SEPARATOR)
            end
          }
        else
          raise "Association :#{association_name} is not defined or not an one-to-many association"
        end
      end
    end
  end
end