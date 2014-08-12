require 'benchmark'

namespace :gtg do
  namespace :import do
    namespace :galleries do
      desc 'Import all remote GT Graphics galleries'
      task :all => [:wallpapers, :artworks, :photos]

      desc 'Import wallpapers from the remote GT Graphics gallery'
      task :wallpapers => :environment do
        path = ENV.fetch('IMPORT_TO') { 'work/wallpapers' }
        gallery_page = Page.find_by! path: path
        import_gallery 'wallpapers', gallery_page
      end

      desc 'Import artworks from the remote GT Graphics gallery'
      task :artworks => :environment do
        path = ENV.fetch('IMPORT_TO') { 'work/artworks' }
        gallery_page = Page.find_by! path: path
        import_gallery 'artworks', gallery_page
      end

      desc 'Import photos from the remote GT Graphics gallery'
      task :photos => :environment do
        path = ENV.fetch('IMPORT_TO') { 'work/photography' }
        gallery_page = Page.find_by! path: path

        %w(nature architecture people misc).each do |subgallery_name|
          subgallery_page = Page.find_by! path: "#{path}/#{subgallery_name}"
          import_gallery subgallery_name, subgallery_page
        end
      end

      class ImagePageParser
        AUTHORS = {
          'Taenaron' => 't.roetsch@gtgraphics.de',
          'gucken' => 'j.michelmann@gtgraphics.de'
        }.freeze

        attr_reader :url, :documents, :default_document

        def initialize(url, locales = I18n.available_locales)
          @url = url
          @documents = locales.inject({}) do |documents_hash, locale|
            documents_hash[locale] = Nokogiri::HTML(open("#{@url}?setlang=#{locale}"))
            documents_hash
          end
          @default_document = @documents.fetch(I18n.default_locale)
        end

        def locale
          @locale ||= I18n.default_locale
        end
        attr_writer :locale

        def current_document
          @document.fetch(self.locale)
        end

        def with_locale(new_locale)
          previous_locale = self.locale
          self.locale = new_locale
          yield
          self.locale = previous_locale
        end

        def title
          current_document.css('.img-title').inner_text.squish
        end

        def description
          current_document.css('.image-box-content p').first.inner_html.squish
        end

        def author
          author_str = default_document.css('.title-ct span:last').text.squish
          if author_str =~ /\A\(by (.*)\)\z/
            image.author = User.find_by!(email: AUTHORS.fetch($1))
          else
            raise "Author not found: #{author_str}"
          end
        end

        def asset_url
          default_document.css('.img-container img').first[:src]
        end

        def variant_asset_urls
          default_document.css('.image-box-content .grid_3 p .home-num-sign').collect { |anchor| anchor[:href] }
        end

        def hits_count
          hits_text = document.css('.image-box-content .grid_3 .zoom-ct').inner_text.squish
          if hits_text =~ /\AViews\: (.*)\z/
            $1.to_i
          else
            0
          end
        end

        def shop_url(key)
          element = document.css(".print-#{key}").first
          element['href'].presence if element
        end
      end

      class GalleryPageParser
        URL_PATTERN = "http://www.gtgraphics.de/category/%{name}/%{page}"

        attr_reader :name, :documents, :default_document

        def initialize(name)
          @name = name
          @default_document = Nokogiri::HTML(open(self.url, 1))
          @documents = 2.upto(self.pages_count).inject({}) do |documents_hash, page|
            documents_hash[page] = Nokogiri::HTML(open(self.url(page)))
            documents_hash
          end
          @documents[1] = @default_document
        end

        def url(page = 1)
          URL_PATTERN % { name: @name, page: page }
        end

        def pages_count
          default_document.css('#gtg-page-content .container_12:last a')[-2].text.to_i
        end

        def current_document
          @documents[self.page]
        end

        def image_page_urls
          current_document.css('.content-top-pic').collect do |element|
            element.css('a').first[:href]
          end
        end

        def page
          @page ||= 1
        end
        attr_writer :page

        def with_page(new_page)
          previous_page = self.page
          self.page = new_page
          yield
          self.page = previous_page
        end
      end

      def import_gallery(name, gallery_page)
        puts "Importing Gallery: #{name.titleize}"

        # Determine Pages Count
        parser = GalleryPageParser.new(name)
        parser.image_page_urls.each do |image_page_url|
          image = import_image(image_page_url)
          create_image_page(image_page_url, gallery_page, image)
        end
      end

      def import_image(image_page_url)
        # Parser for the page we're about to process
        parser = ImagePageParser.new(image_page_url)

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
        parser = ImagePageParser.new(image_page_url)

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
        page.shop_links = {
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