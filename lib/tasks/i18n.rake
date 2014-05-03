namespace :i18n do
  desc 'Generates I18n Javascript files and stores them in public/static/locales'
  task :generate_js do
    translations = Dir.glob("#{Rails.root}/config/locales/**/*.yml").inject({}) do |translations_hash, file|
      translations_hash.deep_merge!(YAML.load_file(file))
    end
    translations.deep_transform_keys! { |key| key.camelize(:lower) }
    translations.each do |locale, translations|
      file_name = "#{Rails.root}/public/static/locales/#{locale}.js"
      dir_name = File.dirname(file_name)
      FileUtils.mkdir_p(dir_name)
      js = %{
        I18n || (I18n = {});
        I18n.translations || (I18n.translations = {});
        I18n.translations.#{locale} = #{translations.to_json};
      }.strip_heredoc.strip
      File.write(file_name, js)
    end
  end
end