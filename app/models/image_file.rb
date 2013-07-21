class ImageFile < ActiveRecord::Base
  has_attached_file :asset

  validates_attachment :asset, presence: true

  serialize :exif_data, OpenStruct
end