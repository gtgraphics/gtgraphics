class Image < ActiveRecord::Base
  class MetaCollection
    def initialize(image)
      @image = image
      @exif_data = image.exif_data
    end

    def [](key)
      try(key)
    end

    delegate :artist, :software, to: :exif_data, allow_nil: true

    def camera_model
      exif_data.model
    end

    def camera_manufacturer
      exif_data.make
    end

    def exposure_time
      exif_data.exposure_time.try(:to_f).try(:seconds)
    end

    def flash_fired?
      (exif_data.flash & 1) == 1
    end

    def iso_speed
      exif_data.iso_speed_ratings
    end

    def resolution
      if exif_data.x_resolution == exif_data.y_resolution
        "#{exif_data.x_resolution.to_i} #{resolution_unit}"
      else
        "#{exif_data.x_resolution.to_i}/#{exif_data.y_resolution.to_i} #{resolution_unit}"
      end
    end

    def resolution_unit
      case exif_data.resolution_unit
      when 1 then nil
      when 2 then :dpi
      when 3 then :dpcm
      end
    end

    def shot_at
      exif_data.date_time
    end

    attr_reader :image, :exif_data
    private :image, :exif_data
  end
end