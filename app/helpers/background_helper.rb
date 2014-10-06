module BackgroundHelper
  def background_image
    @background_image ||= Image.order('RANDOM()').first
  end 

  def background_url
    attached_asset_path(background_image, :custom)
  end 
end