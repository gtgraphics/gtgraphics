module ApplicationHelper
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |available_locale| translate(available_locale, scope: :languages, locale: locale) }
  end

  def microtimestamp
    (Time.now.to_f * 1_000_000).to_i
  end
end
