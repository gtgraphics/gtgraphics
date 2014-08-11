module FieldsetHelper
  def fieldset(legend, options = {}, &block)
    content_tag :fieldset, options do
      concat content_tag(:legend, legend)
      concat content_tag(:div, class: 'fields', &block)
    end
  end
end