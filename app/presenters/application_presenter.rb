class ApplicationPresenter < ActionPresenter::Base
  def attribute_list(*attribute_names)
    options = attribute_names.extract_options!.reverse_merge(hide_blank: true)

    html_options = options.except(:hide_blank)
    html_options[:class] = ['dl-horizontal', *html_options[:class]].compact.uniq

    h.content_tag :dl, html_options do
      attribute_names.flatten.each do |name|
        value = public_send(name)
        next if options[:hide_blank] == true && value.blank?
        h.concat h.content_tag(:dt, object.class.human_attribute_name(name))
        h.concat h.content_tag(:dd, value)
      end
    end
  end

  protected

  def placeholder
    '&ndash;'.html_safe
  end
end
