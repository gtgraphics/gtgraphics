namespace :i18n do
  desc 'Generates I18n Javascript files and stores them in public/static/locales'
  task :generate_js => :environment do
    # Generate contained directory
    dirname = ENV.fetch('DIRNAME') { "#{Rails.root}/public/static/locales" }
    FileUtils.mkdir_p(dirname)

    # Get contents of all translation files and merge them in a single Hash
    locale_files = Dir.glob("#{Rails.root}/config/locales/**/*.yml")
    translations = locale_files.inject({}) do |translations, file|
      locale_translations = YAML.load_file(file)
      locale_translations.deep_transform_keys! do |key|
        key.split('/').map { |part| part.camelize(:lower) }.join('/')
      end
      translations.deep_merge!(locale_translations)
    end

    if I18n.respond_to?(:fallbacks)
      fallback_combinations = I18n.available_locales.collect { |locale| I18n.fallbacks[locale].sort }.uniq
      fallback_combinations.each do |locale_combination|
        file_name = locale_combination.join('+')
        path = File.join(dirname, "#{file_name}.js")
        File.open(path, 'w') do |file|
          file.puts header_data
          locale_combination.each do |locale|
            file.puts translation_data(locale, translations[locale.to_s])
          end
        end
        puts "[#{locale_combination.join('+')}] #{path}"
      end
    else
      translations.each do |locale, locale_translations|
        path = File.join(dirname, "#{locale}.js")
        File.open(path, 'w') do |file|
          file.puts header_data
          file.puts translation_data(locale, locale_translations)
        end
        puts "[#{locale}] #{path}"
      end
    end
  end

  def header_data
    <<-JAVASCRIPT.strip_heredoc
      I18n || (I18n = {});
      I18n.translations || (I18n.translations = {});
    JAVASCRIPT
  end

  def translation_data(locale, translations)
    "I18n.translations.#{locale} = #{translations.to_json};"
  end
end