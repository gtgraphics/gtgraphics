class ImagePreviewInput < SimpleForm::Inputs::FileInput
  def input
    # :preview_version is a custom attribute from :input_html hash, so you can pick custom sizes
    version = input_html_options.delete(:preview_version) { :original }
    html = '' # the htmlput string we're going to build
    # check if there's an uploaded file (eg: edit mode or form not saved)
    if object.send("#{attribute_name}?") and object.errors[attribute_name].empty?
      # append preview image to htmlput
      html << template.content_tag(:div, class: 'clearfix') do
        inner_html = ""
        inner_html << template.content_tag(:div, class: 'pull-left') do
          template.link_to object.send(attribute_name).url, target: '_blank' do
            template.image_tag(object.send(attribute_name, version), class: 'thumbnail', alt: '', style: 'margin-bottom: 10px; margin-right: 10px')
          end
        end
        if object.respond_to?("#{attribute_name}_width") and object.respond_to?("#{attribute_name}_height")
          inner_html << template.content_tag(:div, "#{object.send("#{attribute_name}_width")} &times; #{object.send("#{attribute_name}_height")}".html_safe, style: 'margin-top: 5px')
        end
        inner_html << template.content_tag(:div, class: 'text-muted') do
          file_name = object.send("#{attribute_name}_file_name")
          content_type = object.send("#{attribute_name}_content_type")
          I18n.translate(content_type, scope: :content_types, default: I18n.translate('content_types.default', extension: File.extname(file_name).from(1).upcase, default: content_type))
        end
        inner_html << template.content_tag(:div, class: 'text-muted') do
          template.number_to_human_size(object.send("#{attribute_name}_file_size"))
        end
        inner_html.html_safe
      end
    end
    # append file input. it will work accordingly with your simple_form wrappers
    html << template.content_tag(:div, class: 'btn-toolbar') do
      @builder.file_field(attribute_name, input_html_options)
    end
    html.html_safe
  end
end