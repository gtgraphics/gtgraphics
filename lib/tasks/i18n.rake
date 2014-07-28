namespace :i18n do
  task :scaffold => :environment do
    Rails.application.eager_load!
    ActiveRecord::Base.descendants.each do |model|
      I18n.available_locales.each do |locale|
        model_path = model.name.underscore.split('/').map(&:pluralize).join('/')
        path = "#{Rails.root}/config/locales/#{locale}/#{model_path}.yml"
        if File.exists?(path)
          puts "#{path} exists: skipping"
        else
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, 'w') do |file|


            file.puts %{#{locale}:
  activerecord:
    attributes:}

            begin
              model.column_names.each do |column_name|
                file.puts "      #{column_name}: #{column_name.titleize}"
              end
            rescue
            end

            file.puts %{
  models:
    #{model.name.underscore}:
      one: #{model.name.titleize}
      other: #{model.name.titleize.pluralize}}
          end
          puts "#{path} created"
        end
      end
    end
  end

  desc 'Generates I18n Javascript files and stores them in public/static/locales'
  task :generate_js => :environment do
    # Generate contained directory
    dirname = ENV.fetch('DIRNAME') { "#{Rails.root}/public/static/locales" }
    FileUtils.mkdir_p(dirname)

    # Remove all files from directory
    Dir.glob("#{dirname}/*.js").each { |file| File.delete(file) }

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