class EditorActivity < Activity
   include ActionView::Helpers::TagHelper

   def persisted?
     attributes.values.any?(&:present?)
   end

   def to_html
     raise NotImplementedError, "#{self.name}##{__method__} must be implemented to use the activity"
   end
end