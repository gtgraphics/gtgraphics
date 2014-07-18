class Image::StyleUploader < AttachmentUploader
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  process :set_content_type

  version :custom do
    process :crop
    process :resize

    def full_filename(file)
      "custom/#{file}"
    end
  end

  version :thumbnail, from_version: :custom do
    process resize_to_fill: [300, 300]

    def full_filename(file)
      "thumbnails/#{file}"
    end
  end

  def filename
    "#{model.asset_token}.#{file.extension}"
  end

  def store_dir
    "system/images/styles/#{model.image.asset_token}"
  end

  def cache_dir
    'tmp/uploads/images/styles'
  end

  private
  def crop
    if cropped?
      manipulate! do |img|
        img.crop(model.crop_geometry)
        img = yield(img) if block_given?
        img
      end
    end
  end

  def cropped?
    model.try(:cropped?) || false
  end

  def resize
    if resized?
      manipulate! do |img|
        img.resize(model.resize_geometry)
        img = yield(img) if block_given?
        img
      end
    end
  end

  def resized?
    model.try(:resized?) || false
  end
end