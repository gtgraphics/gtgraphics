class UpdateExifData < ActiveRecord::Migration
  def up
    update 'UPDATE images SET exif_data = NULL'
    say 'Removed all cached Exif metadata'

    Image.find_each do |image|
      image.refresh_exif_data!
      say "Updated: #{image.title}"
    end
  end
end
