class Provider < ActiveRecord::Base
  class LogoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MimeTypes
    include CarrierWave::RMagick

    process :set_content_type

    version :icon do
      process resize_to_fill: [32, 32]

      def full_filename(file)
        "icons/#{file}"
      end
    end

    version :thumbnail do
      process resize_to_fill: [150, 150]

      def full_filename(file)
        "thumbnails/#{file}"
      end
    end

    def filename
      "#{model.asset_token}.#{file.extension}" if file
    end

    def store_dir
      'system/providers'
    end

    def cache_dir
      'tmp/uploads/providers'
    end
  end
end
