module TranslationHelper
  def available_locales_for_select
    I18n.available_locales.map do |locale|
      language_name = translate(locale, scope: :languages)
      unless locale == I18n.locale
        translated_language_name = translate(locale, scope: :languages, locale: locale)
        language_name = "#{language_name} (#{translated_language_name})"
      end
      [language_name, locale]
    end.sort_by(&:first)
  end

  def translation_pane_for(locale, &block)
    content_tag :div, class: 'tab-pane', data: { locale: locale }, &block
  end

  def translation_manager_for(fields_or_object, options = {}, &block)
    content_tag :div, class: 'translation-manager', data: options.deep_merge(behavior: 'translationManager') do
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