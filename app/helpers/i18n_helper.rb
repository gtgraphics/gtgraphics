module I18nHelper 
  def available_locales
    I18n.available_locales.sort_by { |locale| translate(locale, scope: :languages) }
  end

  def i18n_javascript
    fallbacks = I18n.try(:fallbacks)
    locales = Array(fallbacks ? fallbacks[I18n.locale] : I18n.locale)

    capture do
      concat javascript_tag <<-JAVASCRIPT.strip_heredoc
        I18n || (I18n = {});
        I18n.defaultLocale = #{I18n.default_locale.to_json};
        I18n.fallbacks = #{fallbacks.to_h.to_json};
        I18n.locale = #{I18n.locale.to_json};
      JAVASCRIPT
      concat "\n"
      concat javascript_include_tag("/static/locales/#{locales.join('+')}.js")  
    end
  end
end