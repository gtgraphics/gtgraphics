class ImageCopyrightAssignmentJob < Struct.new(:image_ids)
  include Job

  def perform
    Image.where(id: image_ids).find_each(&:refresh_exif_data!)
    Image::Style.where(image_id: image_ids).find_each(&:write_exif_copyright!)
  end
end