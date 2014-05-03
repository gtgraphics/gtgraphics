module I18nHelper 
  def available_locales(locale = I18n.locale)
    I18n.available_locales.sort_by { |available_locale| translate(available_locale, scope: :languages, locale: locale) }
  end

  def i18n_javascript
    capture do
      concat javascript_tag %{
        I18n || (I18n = {});
        I18n.defaultLocale = #{I18n.default_locale.to_json};
        I18n.fallbacks = #{I18n.fallbacks.to_h.to_json};
        I18n.locale = #{I18n.locale.to_json};
      }.strip_heredoc
      concat "\n"
      concat javascript_include_tag("/static/locales/#{I18n.locale}.js")
    end
  end
end