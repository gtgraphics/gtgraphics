module NestedFormHelper
  def nested_form_content_for(object, *nested_association_names, &block)
    nested_association_args = []
    nested_association_names.each do |association_name|
      if association_name.is_a?(Hash)
        association_name.each do |name, options|
          nested_association_args << [name, options]
        end
      else
        nested_association_args << [association_name]
      end
    end
 
    html = nil
    simple_form_for object, url: '' do |form|
      html = _recursive_fields_for_nested_form_content(form, nested_association_args, &block)
    end
    html
  end
 
  private
  def _recursive_fields_for_nested_form_content(parent_fields, nested_association_args, &block)
    if args = nested_association_args.shift
      args.flatten!
      options = args.extract_options!
      if options.delete(:generate_index)
        options[:child_index] = (Time.now.to_f * 1_000_000).to_i # microtime
      end
      parent_fields.simple_fields_for *args, options do |fields|
        _recursive_fields_for_nested_form_content(fields, nested_association_args, &block)
      end
    else
      capture(parent_fields, &block)
    end
  end
end