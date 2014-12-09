namespace :gtg do
  namespace :images do
    desc 'Recreates asset versions on Images'
    task recreate_assets: :environment do
      include_styles = ENV.fetch('INCLUDE_STYLES', false)
      images = include_styles ? Image.includes(:styles) : Image.all
      images.find_each do |image|
        image.recreate_assets!
        image.styles.each(&:recreate_assets!) if include_styles
        puts image.title
      end
    end
  end
end