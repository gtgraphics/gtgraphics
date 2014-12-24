class Image < ActiveRecord::Base
  # This module controls the database caching of the Exif data that is
  # embedded in uploaded images
  module ExifStorable
    extend ActiveSupport::Concern

    included do
      include Image::ExifAnalyzable

      store :exif_data

      before_save :cache_exif_data, if: [:exif_capable?, :asset_changed?]
    end

    def refresh_exif_data!
      write_exif_copyright!
      styles.each(&:write_exif_copyright!)
      cache_exif_data
      save!
    end

    # Accessors for commonly accessed data

    def camera
      exif_data['Model']
    end

    def copyright
      exif_data['Copyright']
    end

    def software
      exif_data['Software']
    end

    def taken_at
      (exif_data['DateTimeOriginal'] || exif_data['DateTimeCreated'] ||
        exif_data['DateTime']).try(:to_datetime)
    end

    private

    def cache_exif_data
      self.exif_data = exif.to_hash
    end
  end
end
