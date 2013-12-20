module NestedFormHelper
  def nested_form_content_for(form_record_object, *field_record_names_or_objects, &block)
    options = field_record_names_or_objects.extract_options!.reverse_merge(url: '')
    html = nil
    simple_form_for form_record_object, options do |form|
      html = _recursive_fields_for_nested_form_content(form, field_record_names_or_objects, &block)
    end
    html
  end
 
  private
  def _recursive_fields_for_nested_form_content(parent_fields, field_record_names_or_objects, &block)
    if field_object = field_record_names_or_objects.shift
      field_args = Array(field_object)
      parent_fields.simple_fields_for *field_args do |fields|
        _recursive_fields_for_nested_form_content(fields, field_record_names_or_objects, &block)
      end
    else
      capture(parent_fields, &block)
    end
  end
end