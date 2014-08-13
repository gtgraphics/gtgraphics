namespace :gtg do
  namespace :truncate do
    namespace :galleries do

      desc 'Truncate all GT Graphics galleries'
      task :all => [:wallpapers, :artworks, :photos]

      desc 'Truncate wallpapers in the GT Graphics gallery'
      task :wallpapers => :environment do
        gallery_page = Page.find_by! path: 'work/wallpapers'
        gallery_page.children.destroy_all
      end

      desc 'Truncate artworks in the GT Graphics gallery'
      task :artworks => :environment do
        gallery_page = Page.find_by! path: 'work/artworks'
        gallery_page.children.destroy_all
      end

      desc 'Truncate photos in the GT Graphics gallery'
      task :photos => :environment do
        path = 'work/photography'
        gallery_page = Page.find_by! path: path
        %w(nature architecture people misc).each do |subgallery_name|
          subgallery_page = Page.find_by! path: "#{path}/#{subgallery_name}"
          subgallery_page.children.destroy_all
        end
      end

    end
  end
end