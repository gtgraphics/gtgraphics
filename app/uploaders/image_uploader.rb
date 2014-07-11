class ImageUploader < AttachmentUploader
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

  version :social, from_version: :custom do
    process resize_to_fill: [500, 500]

    def full_filename(file)
      "social/#{file}"
    end
  end

  def filename
    "#{model.asset_token}.#{file.extension}"
  end

  def store_dir
    "system/images"
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