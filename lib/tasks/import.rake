namespace :gtg do
  namespace :import do
    AUTHOR_MAPPINGS = {
      'Taenaron' => ['Tobias', 'Roetsch'],
      'gucken' => ['Jeff', 'Michelmann']
    }

    GALLERY_URL_PATTERN = "http://gtgraphics.de/category/%{gallery_name}/%{page}"

    desc 'Import a remote GT Graphics Gallery to the local database'
    task :galleries => :environment do
      Page.transaction do
        work_page = Page.find_by(path: 'work')
        # work_page = FactoryGirl.create :content_page
        # import_gallery 'artworks', 'work'
        # import_gallery 'artworks', 'work'
      end
    end

    def import_gallery(gallery_name, page, template = Template::Image.default)
      parent_page = Page.find_by!(path: mount_path)

      gallery_doc = Nokogiri::HTML(open(GALLERY_URL_PATTERN % { gallery_name: gallery_name, page: 1 }))
      pages_count = gallery_doc.css('#gtg-page-content .container_12:last a')[-2].text.to_i

      1.upto(pages_count) do |page|
        gallery_doc = Nokogiri::HTML(open(GALLERY_URL_PATTERN % { gallery_name: gallery_name, page: page }))
        gallery_doc.css('.content-top-pic').each do |element|
          image_page_url = element.css('a').attr('href')

          additional_debug_info = nil

          @image = nil
          @page = nil

          I18n.available_locales.each_with_index do |locale, index|
            concrete_image_page_url = "#{image_page_url}?setlang=#{locale}"

            image_doc = Nokogiri::HTML(open(concrete_image_page_url))
            image_title = image_doc.css('.img-title').inner_text.squish

            image_author_text = image_doc.css('.title-ct span:last').text()
            image_author = AUTHOR_MAPPINGS[AUTHOR_MAPPINGS.keys.detect { |nickname| image_author_text.include?(nickname) }]

            image_description = image_doc.css('.image-box-content p').first.inner_html.squish
            if index.zero?
              remote_asset_url = image_doc.css('.gtg-img').attr('src')
              virtual_file_name = image_title.parameterize('_') + File.extname(remote_asset_url).downcase
            end

            # Create Image and Translations
            @image ||= Image.find_or_initialize_by(asset_file_name: virtual_file_name).tap do |image|
              image.author = User.find_by(first_name: image_author.first, last_name: image_author.last) if image_author
            end
            @image.translations.find_or_initialize_by(locale: locale).tap do |translation|
              translation.title = image_title
              translation.description = image_description
            end

            # Create Page
            if parent_page
              @page ||= parent_page.children.images.detect { |page| page.embeddable.image == @image } || parent_page.children.images.new
              @page.translations.find_or_initialize_by(locale: locale).tap do |translation|
                translation.title = image_title
              end
              @page.state = 'published'
              @page.build_embeddable(image: @image, template: template)
            end

            # Retrieve and store remote asset on first iteration
            if index.zero?
              # Original Asset
              puts "Fetching: #{remote_asset_url}"
              @image.asset = open(remote_asset_url)
              @image.asset_file_name = virtual_file_name

              # Style Assets
              image_style_urls = image_doc.css('.home-num-sign').collect { |style_element| style_element.attr('href') }
              image_style_urls.each do |remote_style_asset_url|
                virtual_style_file_name = image_title.parameterize('_') + '_' + File.basename(remote_style_asset_url).split('-').last.downcase
                @image.custom_styles.find_or_initialize_by(type: 'Image::Style::Attachment', asset_file_name: virtual_style_file_name).tap do |style|
                  puts "Fetching: #{remote_style_asset_url}"
                  style.asset = open(remote_style_asset_url)
                  style.asset_file_name = virtual_style_file_name
                end
              end
              additional_debug_info = " (+ #{image_style_urls.count} styles)" if image_style_urls.any?
            end
          end

          @image.save!
          @page.save! if @page

          puts "Imported: #{@image.title} (#{@image.asset_file_name})#{additional_debug_info}"
          puts "Created Page: #{@page.path}" if @page
        end
      end
    end
  end
end