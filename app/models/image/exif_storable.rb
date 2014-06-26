module Image::ExifStorable
  extend ActiveSupport::Concern

  EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

  included do
    serialize :exif_data, OpenStruct

    delegate :software, to: :exif_data, allow_nil: true
  end

  module ClassMethods
    def exif_capable_content_types
      EXIF_CAPABLE_CONTENT_TYPES
    end
  end

  def camera
    exif_data.try(:model)
  end

  def taken_at
    exif_data.try(:date_time_original).try(:to_datetime)
  end
  
  private
  def set_exif_data
    if asset_content_type.in?(EXIF_CAPABLE_CONTENT_TYPES)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end
end