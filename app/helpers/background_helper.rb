module BackgroundHelper
  def background_image
    @background_image ||= Image.joins(:pages).
      where(pages: { id: Page.find_by(path: 'wallpapers').try(:self_and_descendants) }).
      order('RANDOM()').first
  end 

  def background_url
    attached_asset_path(background_image, :custom) if background_image
  end 
end