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
      cache_exif_data
      save!
    end

    # Accessors for commonly accessed data

    def artist
      @artist ||= User.find_by_name(artist_name) if artist_name.present?
    end

    def artist_name
      exif_data['Artist'] || exif_data['Creator'] || exif_data['By-line']
    end

    {
      camera_manufacturer: 'Make',
      camera: 'Model',
      copyright: 'Copyright',
      iso_value: 'ISO',
      f_number: 'FNumber',
      focal_length: 'FocalLength',
      exposure_time: 'ExposureTime',
      lens_model: 'LensModel',
      software: 'Software'
    }.each do |reader, exif_attr|
      define_method reader do
        exif_data[exif_attr]
      end
    end

    def orientation
      if exif_data['Orientation'] =~ /horizontal/i
        :landscape
      else
        :portrait
      end
    end

    def taken_at
      (exif_data['DateTimeOriginal'] || exif_data['DateTimeCreated'] ||
        exif_data['DateTime']).try(:to_datetime)
    end

    private

    def cache_exif_data
      self.exif_data = metadata
    rescue MiniExiftool::Error => error
      logger.error "Error reading Exif data: #{error.message}"
      self.exif_data = {}
    end
  end
end
