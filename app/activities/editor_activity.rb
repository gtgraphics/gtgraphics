class EditorActivity < Activity
   include ActionView::Helpers::TagHelper

   def initialize(attributes = {})
     self.persisted = attributes.any?
     super
   end

   def self.from_params(params)
     attribute_names = attribute_set.map(&:name)
     attributes = params.slice(*attribute_names)
     new(attributes)
   end

   def persisted?
     @persisted
   end

   attr_writer :persisted

   def to_html
     raise NotImplementedError, "#{self.name}##{__method__} must be implemented to use the activity"
   end
end