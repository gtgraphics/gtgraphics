module I18nHelper 
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |available_locale| translate(available_locale, scope: :languages, locale: locale) }
  end

  def i18n_javascript
    javascript_tag do
      locale_json = ->(locale) { I18n.translate(:javascript, locale: locale, default: {}).deep_transform_keys { |key| key.to_s.camelize(:lower) }.to_json }
      js = %{
        I18n || (I18n = {});
        I18n.defaultLocale = '#{I18n.default_locale}';
        I18n.locale = '#{I18n.locale}';
        I18n.translations = {};
        I18n.translations.#{I18n.locale} = #{locale_json.call(I18n.locale)};
      }.strip_heredoc
      if signed_in? and current_user.preferred_locale and I18n.locale != current_user.preferred_locale.to_sym
        js << %{
          I18n.translations.#{current_user.preferred_locale} = #{locale_json.call(current_user.preferred_locale)};
        }.strip_heredoc
      end
      raw js
    end
  end
end