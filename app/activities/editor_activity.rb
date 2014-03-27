class EditorActivity < Activity
   include ActionView::Helpers::TagHelper

   def self.from_html(html)
     raise NotImplementedError, "#{self.name}::#{__method__} must be implemented to use the activity"
   end

   def to_html
     raise NotImplementedError, "#{self.name}##{__method__} must be implemented to use the activity"
   end
end