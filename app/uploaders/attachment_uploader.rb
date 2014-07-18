class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  process :set_content_type

  def filename
    "#{model.asset_token}.#{file.extension}"
  end

  def store_dir
    'system/files'
  end

  def cache_dir
    'tmp/uploads/attachments'
  end
end