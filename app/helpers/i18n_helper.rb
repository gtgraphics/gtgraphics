module I18nHelper
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |available_locale| translate(available_locale, scope: :languages, locale: locale) }
  end
  
  def i18n_javascript
    javascript_tag do
      raw %{
        window.I18n || (window.I18n = {});
        window.I18n.locale = '#{I18n.locale}';
        window.I18n.translations = #{I18n.translate(:javascript, default: {}).to_json};
      }
    end
  end
end