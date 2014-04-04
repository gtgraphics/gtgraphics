class EditorActivity < Activity
   include ActionView::Helpers::TagHelper

   after_initialize do
     self.persisted = false if @persisted.nil?
   end

   def self.from_params(params)
     attribute_names = attribute_set.map(&:name)
     attributes = params.slice(*attribute_names)
     new(attributes).tap do |activity|
       activity.persisted = attributes.any?
     end
   end

   def persisted?
     @persisted
   end

   attr_writer :persisted

   def to_html
     raise NotImplementedError, "#{self.name}##{__method__} must be implemented to use the activity"
   end
end