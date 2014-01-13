module TranslationHelper
  def translation_pane_for(locale, &block)
    content_tag :div, class: 'tab-pane', data: { locale: locale }, &block
  end

  def translation_manager_for(fields_or_object, options = {}, &block)
    url = options.fetch(:url)
    content_tag :div, class: 'translation-manager', data: { load_url: url, load_format: options[:format] } do
      inner_html = render 'locale_changer', object: block_given? ? fields_or_object : fields_or_object.object
      inner_html << content_tag(:div, class: 'tab-content') do
        if block_given?
          capture(&block)
        else
          fields_or_object.simple_fields_for :translations do |translation_fields|
            render 'translation_fields', fields: translation_fields
          end
        end
      end
    end
  end
end