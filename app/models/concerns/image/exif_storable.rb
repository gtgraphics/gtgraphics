class Image < ActiveRecord::Base
  module ExifStorable
    extend ActiveSupport::Concern

    EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

    included do
      store :exif_data

      before_save :set_exif_data, if: [:asset_changed?, :exif_capable?]
    end

    module ClassMethods
      def exif_capable_content_types
        exif_capable_mime_types.map(&:to_s)
      end

      def exif_capable_mime_types
        EXIF_CAPABLE_CONTENT_TYPES
      end
    end

    def camera
      exif_data[:model]
    end

    def exif_capable?
      content_type.in?(self.class.exif_capable_content_types)
    end

    def software
      exif_data[:software]
    end

    def taken_at
      exif_data[:date_time_original].try(:to_datetime)
    end
    
    private
    def set_exif_data
      self.exif_data = EXIFR::JPEG.new(asset.path).to_hash rescue nil
    end
  end
end