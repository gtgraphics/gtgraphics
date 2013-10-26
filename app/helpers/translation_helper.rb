module TranslationHelper
  def translation_pane_for(locale, &block)
    css = 'tab-pane'
    css << ' active' if locale == I18n.locale
    content_tag :div, class: css, id: locale, data: { locale: locale }, &block
  end
end