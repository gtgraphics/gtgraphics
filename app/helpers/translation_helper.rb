module TranslationHelper
  def translation_pane_for(locale, id = nil, &block)
    #css = 'tab-pane'
    #css << ' active' if locale == I18n.locale
    content_tag :div, class: 'tab-pane', id: id, data: { locale: locale }, &block
  end

  def translation_manager_for(fields_or_object, options = {}, &block)
    url = options.fetch(:url)
    content_tag :div, class: 'translation-manager', data: { url: url } do
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