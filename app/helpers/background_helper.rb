module BackgroundHelper
  def background_image
    @background_image ||= Image.tagged('Wallpaper').sample
  end 

  def background_url
    attached_asset_path(background_image, :custom) if background_image
  end 
end