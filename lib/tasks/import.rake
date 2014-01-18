namespace :gtg do
  namespace :import do
    desc 'Import a remote GT Graphics Gallery to the local database'
    task :gallery => :environment do
      gallery_name = ENV['GALLERY'] || raise('GALLERY not specified')
      gallery_url = "http://gtgraphics.de/category/#{gallery_name}"

      AUTHOR_MAPPINGS = {
        'Taenaron' => ['Tobias', 'Roetsch'],
        'gucken' => ['Jeff', 'Michelmann']
      }

      gallery_doc = Nokogiri::HTML(open(gallery_url))
      pages_count = gallery_doc.css('#gtg-page-content .container_12:last a')[-2].text.to_i

      #Image.transaction do
        1.upto(pages_count) do |page|
          paginated_gallery_url = "#{gallery_url}/#{page}"

          gallery_doc = Nokogiri::HTML(open(paginated_gallery_url))
          gallery_doc.css('.content-top-pic').each do |element|
            image_page_url = element.css('a').attr('href')

            @image = nil

            I18n.available_locales.each_with_index do |locale, index|
              concrete_image_page_url = "#{image_page_url}?setlang=#{locale}"

              image_doc = Nokogiri::HTML(open(concrete_image_page_url))
              image_title = image_doc.css('.img-title').inner_text.squish

              image_author_text = image_doc.css('.title-ct span:last').text()
              image_author = AUTHOR_MAPPINGS[AUTHOR_MAPPINGS.keys.detect { |nickname| image_author_text.include?(nickname) }]

              image_description = image_doc.css('.image-box-content p').first.inner_html.squish
              if index.zero?
                remote_asset_url = image_doc.css('.gtg-img').attr('src')
                virtual_file_name = image_title.parameterize('_') + File.extname(remote_asset_url)
              end

              # Create Image and Translations
              @image ||= Image.find_or_initialize_by(asset_file_name: virtual_file_name).tap do |image|
                image.author = User.find_by(first_name: image_author.first, last_name: image_author.last) if image_author
              end
              @image.translations.find_or_initialize_by(locale: locale).tap do |translation|
                translation.title = image_title
                translation.description = image_description
              end

              # Retrieve and store remote asset on first iteration
              if index.zero?
                @image.asset = open(remote_asset_url)
                @image.asset_file_name = virtual_file_name
              end

              # TODO Image Styles
              if index.zero?
                #image_style_urls = image_doc.css('.home-num-sign').collect { |style_element| style_element.attr('href') }
              end
            end

            @image.save!

            puts "Imported: #{@image.title} (#{@image.asset_file_name})"
          end
        end
      #end
    end
  end
end