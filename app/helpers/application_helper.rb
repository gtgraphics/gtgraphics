module ApplicationHelper
  def admin_controller?
    controller.class.name.split('::').first == 'Admin'
  end

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

  def body_css
    classes = []
    classes << I18n.locale.to_s
    classes << 'admin' if admin_controller?
    classes.join(' ')
  end

  def microtimestamp
    (Time.now.to_f * 1_000_000).to_i
  end
end
