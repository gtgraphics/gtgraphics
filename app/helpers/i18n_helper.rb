module I18nHelper
  def available_locales
    I18n.available_locales.sort_by { |locale| translate(locale, scope: :languages) }
  end

  def next_locale
    @next_locale ||= begin
      index = I18n.available_locales.index(I18n.locale).next % I18n.available_locales.count
      locale = I18n.available_locales[index]
      locale if locale != I18n.locale
    end
  end

  def i18n_javascript_file(*locales)
    fallbacks = I18n.try(:fallbacks)
    locales = locales.flatten.sort
    if locales.empty?
      locales = Array(fallbacks ? fallbacks[I18n.locale] : I18n.locale).sort
    end
    path = "static/locales/#{locales.join('+')}.js"
    timestamp = File.mtime(File.join("#{Rails.root}/public/#{path}")).to_i
    javascript_include_tag("/#{path}?#{timestamp}")
  end

  def i18n_javascript_data
    if I18n.respond_to?(:fallbacks)
      locales = Array(I18n.fallbacks[I18n.locale])
    else
      locales = Array(I18n.locale)
    end

    locale_files = Dir.glob("#{Rails.root}/config/locales/**/*.yml")
    translations = locale_files.each_with_object({}) do |file, translated|
      translated.deep_merge!(YAML.load_file(file))
    end

    js = StringIO.new
    js.write(<<-JAVASCRIPT.strip_heredoc)
      window.I18n || (window.I18n = {});
      I18n.translations || (I18n.translations = {});
    JAVASCRIPT

    locales.each do |locale|
      locale_translations = translations[locale.to_s]
      next if locale_translations.nil?
      js.write(<<-JAVASCRIPT.strip_heredoc)
        I18n.translations.#{locale} = #{locale_translations.to_json};
      JAVASCRIPT
    end

    javascript_tag(js.string)
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
