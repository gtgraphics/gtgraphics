class EditorActivity < Activity
   include ActionView::Helpers::TagHelper

   def self.from_params(params)
     attribute_names = attribute_set.map(&:name)
     attributes = (params || {}).symbolize_keys.slice(*attribute_names)
     new(attributes)
   end

   def persisted?
     attributes.values.any?(&:present?)
   end

   def to_html
     raise NotImplementedError, "#{self.name}##{__method__} must be implemented to use the activity"
   end
end