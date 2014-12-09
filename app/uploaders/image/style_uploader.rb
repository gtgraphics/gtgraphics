class Image::StyleUploader < AttachmentUploader
  include ImageUploadable

  self.watermark = true

  def store_dir
    "system/images/styles/#{model.image.asset_token}"
  end

  def cache_dir
    'tmp/uploads/images/styles'
  end
end