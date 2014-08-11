class AffixedStringInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    prefix = input_html_options.delete(:prefix)
    suffix = input_html_options.delete(:suffix)
    raise ArgumentError, 'no affix defined' if prefix.nil? and suffix.nil?

    template.content_tag :div, class: 'form-control form-control-affixed' do
      insert_affix(prefix)
      template.concat @builder.text_field(attribute_name, class: 'form-control-input')
      insert_affix(suffix)
    end
  end

  private
  def insert_affix(args)
    if args.is_a?(Array)
      options = args.extract_options!
      caption = args.first
    else
      caption = args
    end
    if caption.present?
      options ||= {}
      options[:class] = "form-control-affix form-control-suffix #{options[:class]}".strip
      template.concat template.content_tag(:span, caption, options)
    end
  end
end