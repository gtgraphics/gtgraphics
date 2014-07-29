require 'benchmark'

namespace :gtg do
  namespace :import do
    namespace :galleries do
      AUTHORS = {
        'Taenaron' => 't.roetsch@gtgraphics.de',
        'gucken' => 'j.michelmann@gtgraphics.de'
      }.freeze

      GALLERY_URL_PATTERN = "http://www.gtgraphics.de/category/%{name}/%{page}"

      desc 'Import all remote GT Graphics galleries'
      task :all => [:wallpapers, :artworks, :photos]

      desc 'Import wallpapers from the remote GT Graphics gallery'
      task :wallpapers => :environment do
        path = ENV.fetch('path') { 'work/wallpapers' }
        gallery_page = Page.find_by! path: path
        import_gallery 'wallpapers', gallery_page
      end

      desc 'Import artworks from the remote GT Graphics gallery'
      task :artworks => :environment do
        path = ENV.fetch('path') { 'work/artworks' }
        gallery_page = Page.find_by! path: path
        import_gallery 'artworks', gallery_page
      end

      desc 'Import photos from the remote GT Graphics gallery'
      task :photos => :environment do
        path = ENV.fetch('path') { 'work/photography' }
        gallery_page = Page.find_by! path: path

        %w(nature architecture people misc).each do |name|
          subgallery_page = Page.find_by! path: "#{path}/#{name}"
          import_gallery name, subgallery_page
        end
      end

      def import_gallery(name, gallery_page)
        puts "Importing Gallery: #{name.titleize}..."

        # Determine Pages Count
        gallery_urls = remote_gallery_urls(name)
        gallery_urls.each do |gallery_url|
          gallery_doc = Nokogiri::HTML(open(gallery_url))
          gallery_doc.css('.content-top-pic').each do |element|
            image_page_url = element.css('a').attr('href')
            import_image(image_page_url, gallery_page)
          end
        end
      end

      def import_image(image_url, gallery_page)
        # The image we want to create
        image = Image.new

        # Get documents in all available locales
        documents = I18n.available_locales.inject({}) do |document_hash, locale|
          document_hash.merge! locale => Nokogiri::HTML(open("#{image_url}?setlang=#{locale}"))
        end

        Image.transaction do
          # The default document
          document = documents.fetch(I18n.default_locale)

          # Some debug output
          title = document.css('.img-title').inner_text.squish
          puts "Importing Image: #{title}"

          # Author 
          author_str = document.css('.title-ct span:last').text.squish
          if author_str =~ /\A\(by (.*)\)\z/
            image.author = User.find_by!(email: AUTHORS.fetch($1))
          else
            raise "Author not found: #{author_str}"
          end

          # Assets
          image_url = document.css('.img-container img').first[:src]
          variant_urls = document.css('.image-box-content .grid_3 p .home-num-sign').collect { |anchor| anchor[:href] }      
          image.remote_asset_url = variant_urls.last || image_url
          image.original_filename = File.basename(image.remote_asset_url)

          # Collect I18n related information
          documents.each do |locale, document|
            Globalize.with_locale(locale) do
              image.title = document.css('.img-title').inner_text.squish
              image.description = document.css('.image-box-content p').first.inner_html.squish
              image.tag gallery_page.title(locale)
            end
          end

          image.save!

          puts "- #{image.remote_asset_url}"

          # Variants
          variant_urls.each do |variant_url|
            style = image.styles.new
            style.remote_asset_url = variant_url
            style.original_filename = File.basename(variant_url)
            style.save!

            puts "- #{style.remote_asset_url}"
          end
        end

        # Page
        create_page(documents, gallery_page, image)
      end

      def create_page(documents, gallery_page, image)
        document = documents.fetch(I18n.default_locale)
        hits_text = document.css('.image-box-content .grid_3 .zoom-ct').inner_text.squish
        if hits_text =~ /\AViews\: (.*)\z/
          hits_count = $1.to_i
        else
          hits_count = 0
        end

        page = gallery_page.children.images.new
        page.build_embeddable(image: image, template: "Template::Image".constantize.default)
        page.hits_count = hits_count

        # Set Meta Description
        I18n.available_locales.each do |locale|
          Globalize.with_locale(locale) do
            page.meta_description = image.description # TODO Strip Tags
          end
        end

        page.save!
        page
      end

      def remote_gallery_urls(name)
        first_page_url = remote_gallery_url(name)
        document = Nokogiri::HTML(open(first_page_url))
        pages_count = document.css('#gtg-page-content .container_12:last a')[-2].text.to_i

        1.upto(pages_count).collect do |page|
          remote_gallery_url(name, page)
        end
      end

      def remote_gallery_url(name, page = 1)
        name = Array(name).join(',')
        GALLERY_URL_PATTERN % { name: name, page: page }
      end
    end
  end
end