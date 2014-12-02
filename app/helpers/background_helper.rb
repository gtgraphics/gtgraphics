module BackgroundHelper
  def background_image
    @background_image ||= Image.tagged('Wallpaper').except(:distinct).order('RANDOM()').first
  end 

  def background_url
    attached_asset_path(background_image, :custom) if background_image
  end 
end