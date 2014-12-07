namespace :gtg do
  namespace :images do
    desc 'Recreates asset versions on Images'
    task recreate_assets: :environment do
      Image.all.each do |image|
        image.recreate_assets!
        puts image.title
      end
    end
  end
end