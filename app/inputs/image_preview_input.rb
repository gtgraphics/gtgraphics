class ImagePreviewInput < SimpleForm::Inputs::FileInput
  def input
    # :preview_version is a custom attribute from :input_html hash, so you can pick custom sizes
    version = input_html_options.delete(:preview_version) { :original }
    html = '' # the htmlput string we're going to build
    # check if there's an uploaded file (eg: edit mode or form not saved)
    if object.send("#{attribute_name}?")
      # append preview image to htmlput
      html << template.content_tag(:div, class: 'clearfix') do
        inner_html = ""
        inner_html << template.content_tag(:div, class: 'pull-left') do
          template.link_to object.send(attribute_name).url, target: '_blank' do
            template.image_tag(object.send(attribute_name, version), class: 'thumbnail', style: 'margin-bottom: 10px; margin-right: 10px')
          end
        end
        inner_html << template.content_tag(:div, style: 'margin-top: 5px') do
          object.dimensions.to_s
        end
        inner_html << template.content_tag(:div, class: 'text-muted') do
          I18n.translate(object.send("#{attribute_name}_content_type"), scope: :content_types)          
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