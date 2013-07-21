class Image < ActiveRecord::Base
  class File < ActiveRecord::Base
    self.table_name = 'image_files'

    has_attached_file :asset

    validates_attachment :asset, presence: true

    serialize :exif_data, OpenStruct

    before_save :set_exif_data

    private
    def set_exif_data
      self.exif_data = EXIFR::JPEG.new(asset.queued_for_write[:original].path)
    end
  end
end