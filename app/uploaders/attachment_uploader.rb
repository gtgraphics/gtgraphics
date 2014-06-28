class AttachmentUploader < CarrierWave::Uploader::Base
  process :set_content_type

  def filename
    if original_filename
      if model and model.read_attribute(mounted_as).present?
        model.read_attribute(mounted_as)
      else
        # new filename
        "#{SecureRandom.uuid}.#{file.extension}"
      end
    end
  end

  def cache_dir
    'tmp/uploads'
  end

  def store_dir
    "public/system/files"
  end
end