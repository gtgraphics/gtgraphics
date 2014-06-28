class Image::StyleUploader < ImageUploader
  include CarrierWave::MiniMagick

  def store_dir
    "public/system/images/styles"
  end

  def store_dir
    "system/images/styles/#{model.image.asset_token}"
  end
end