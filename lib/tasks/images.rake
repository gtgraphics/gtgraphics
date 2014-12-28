namespace :gtg do
  namespace :images do
    desc 'Recreates asset versions on Images'
    task recreate_assets: :environment do
      include_styles = ENV.fetch('INCLUDE_STYLES', true).to_b
      images = include_styles ? Image.includes(:styles) : Image.all
      images.find_each do |image|
        image.recreate_assets!
        image.styles.each(&:recreate_assets!) if include_styles

        if include_styles && image.styles.size > 0
          puts "#{image.title} + #{image.styles.size} Styles"
        else
          puts image.title
        end
      end
    end
  end
end
