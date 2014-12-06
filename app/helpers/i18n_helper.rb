module I18nHelper 
  def available_locales
    I18n.available_locales.sort_by { |locale| translate(locale, scope: :languages) }
  end

  def i18n_javascript_file(*locales)
    fallbacks = I18n.try(:fallbacks)
    locales = locales.flatten.sort
    locales = Array(fallbacks ? fallbacks[I18n.locale] : I18n.locale).sort if locales.empty?
    path = "static/locales/#{locales.join('+')}.js"
    timestamp = File.mtime(File.join("#{Rails.root}/public/#{path}")).to_i
    javascript_include_tag("/#{path}?#{timestamp}")
  end

  def i18n_javascript
    fallbacks = I18n.try(:fallbacks)
    javascript_tag <<-JAVASCRIPT.strip_heredoc
      window.I18n || (window.I18n = {});
      I18n.defaultLocale = #{I18n.default_locale.to_json};
      I18n.fallbacks = #{fallbacks.to_h.to_json};
      I18n.locale = #{I18n.locale.to_json};
    JAVASCRIPT
  end
end