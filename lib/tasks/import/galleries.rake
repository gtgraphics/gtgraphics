namespace :gtg do
  namespace :import do
    namespace :galleries do
      desc 'Import all remote GT Graphics galleries'
      task :all => [:wallpapers, :artworks, :photos]

      desc 'Import wallpapers from the remote GT Graphics gallery'
      task :wallpapers => :environment do
        gallery_page = Page.find_by! path: 'work/wallpapers'
        import_gallery 'wallpapers', gallery_page
      end

      desc 'Import artworks from the remote GT Graphics gallery'
      task :artworks => :environment do
        gallery_page = Page.find_by! path: 'work/artworks'
        import_gallery 'artworks', gallery_page
      end

      desc 'Import photos from the remote GT Graphics gallery'
      task :photos => :environment do
        path = 'work/photography'
        gallery_page = Page.find_by! path: path
        %w(nature architecture people misc).each do |subgallery_name|
          subgallery_page = Page.find_by! path: "#{path}/#{subgallery_name}"
          import_gallery subgallery_name, subgallery_page
        end
      end

      def import_gallery(name, gallery_page)
        parser = Import::GalleryPageParser.new(name)

        puts "Importing Gallery: #{name.titleize} (#{parser.pages_count} Pages)"

        parser.page_urls.each do |image_page_url|
          image = import_image(image_page_url)
          create_image_page(image_page_url, gallery_page, image)
        end
      end

      def import_image(image_page_url)
        # Parser for the page we're about to process
        parser = Import::ImagePageParser.new(image_page_url)

        # The image we want to create
        image = Image.new

        # Author 
        image.author = parser.author

        # Assets
        variant_urls = parser.variant_asset_urls
        image.remote_asset_url = variant_urls.last || parser.asset_url
        image.original_filename = File.basename(image.remote_asset_url)

        # Collect I18n related information
        I18n.available_locales.each do |locale|
          Globalize.with_locale(locale) do
            parser.with_locale(locale) do
              image.title = parser.title
              image.description = parser.description
            end
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

        image
      end

      def create_image_page(image_page_url, gallery_page, image)
        parser = Import::ImagePageParser.new(image_page_url)

        page = gallery_page.children.images.new
        page.build_embeddable(image: image, template: "Template::Image".constantize.default)

        # Title and Meta Description
        I18n.available_locales.each do |locale|
          Globalize.with_locale(locale) do
            page.title = image.title
            page.meta_description = HTML::FullSanitizer.new.sanitize(image.description)
          end
        end

        # Hits Count
        page.hits_count = parser.hits_count
       
        # Avoid path collisions by determining the next available slug
        page.set_next_available_slug

        # Metadata
        page.metadata[:social_uri] = image_page_url

        # Shop Links
        page.embeddable.shop_urls = {
          deviantart:   parser.shop_url('da'),
          fineartprint: parser.shop_url('fineartprint'),
          mygall:       parser.shop_url('mygall'),
          redbubble:    parser.shop_url('redbubble'),
          artflakes:    parser.shop_url('artflakes')
        }

        # Persist and return Page
        page.tap(&:save!)
      end
    end
  end
end