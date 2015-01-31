class User::PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick
  include ImageQualityAdjustable

  process :set_content_type

  version :thumbnail do
    process resize_to_fill: [100, 100]
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "thumbnails/#{file}"
    end
  end

  version :menu_brick do
    process resize_to_fill: [530, 200]
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "menu_bricks/#{file}"
    end
  end

  def filename
    "#{model.asset_token}.#{file.extension}" if file
  end

  def store_dir
    'system/users'
  end

  def cache_dir
    'tmp/uploads/users'
  end
end
