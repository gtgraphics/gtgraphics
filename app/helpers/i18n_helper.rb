module I18nHelper 
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |available_locale| translate(available_locale, scope: :languages, locale: locale) }
  end

  def i18n_javascript
    javascript_tag do
      raw %{
        I18n || (I18n = {});
        I18n.defaultLocale = '#{I18n.default_locale}';
        I18n.locale = '#{I18n.locale}';
        I18n.translations = #{I18n.translate(:javascript, default: {}).deep_transform_keys { |key| key.to_s.camelize(:lower) }.to_json};
      }
    end
  end
end