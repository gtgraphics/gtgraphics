namespace :gtg do
  namespace :truncate do
    namespace :galleries do
      desc 'Truncate all GTGRAPHICS galleries'
      task :all => [:wallpapers, :artworks, :photos]

      desc 'Truncate wallpapers in the GTGRAPHICS gallery'
      task :wallpapers => :environment do
        gallery_page = Page.find_by! path: 'work/wallpapers'
        destroy_images_and_pages_in(gallery_page)
      end

      desc 'Truncate artworks in the GTGRAPHICS gallery'
      task :artworks => :environment do
        gallery_page = Page.find_by! path: 'work/artworks'
        destroy_images_and_pages_in(gallery_page)
      end

      desc 'Truncate photos in the GTGRAPHICS gallery'
      task :photos => :environment do
        %w(nature architecture people misc).each do |subgallery_name|
          subgallery_page = Page.find_by! path: "work/photography/#{subgallery_name}"
          destroy_images_and_pages_in(subgallery_page)
        end
      end

      def destroy_images_and_pages_in(gallery_page)
        Image.joins(:pages).where(
          Page.arel_table[:id].in(gallery_page.descendants.select(:id).project)
        ).readonly(false).destroy_all
        puts "Destroyed images used in #{gallery_page.path}"

        puts "Destroyed pages in #{gallery_page.path}"
        gallery_page.children.destroy_all
      end
    end
  end
end
