module BackgroundHelper
  BACKGROUND_TAG = 'Layout'

  def background_image
    @background_image ||= Image.tagged(BACKGROUND_TAG).sample
  end 

  def background_url
    attached_asset_path(background_image, :custom) if background_image
  end 
end