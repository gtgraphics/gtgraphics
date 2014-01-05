module TranslationHelper
  def translation_pane_for(locale, id = nil, &block)
    #css = 'tab-pane'
    #css << ' active' if locale == I18n.locale
    content_tag :div, class: 'tab-pane', id: id, data: { locale: locale }, &block
  end
end