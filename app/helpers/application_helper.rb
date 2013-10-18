module ApplicationHelper
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |locale| translate(locale, scope: :languages, locale: locale) }
  end
end
