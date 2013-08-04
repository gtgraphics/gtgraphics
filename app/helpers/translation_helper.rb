module TranslationHelper
  def translation_select(options = {})
    options[:class] ||= ""
    options[:class] << ' translation-select form-control only-js'
    options[:class].strip!
    content_tag :select, nil, options
  end

  def translations_for(locale, &block)
    content_tag :div, class: "translations locale-#{locale}", data: { locale: locale, language: translate(locale, scope: :locales) }, &block
  end
end