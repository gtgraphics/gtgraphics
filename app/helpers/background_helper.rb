module BackgroundHelper
  BACKGROUND_TAG = 'Layout'

  def background_image
    @background_image ||= Image.tagged(BACKGROUND_TAG).sample
  end

  def background_url
    attached_asset_path(background_image, :custom) if background_image
  end

  def background_image_tag(options = {})
    options = options.reverse_merge(alt: background_image.title)
    image_tag background_url, options
  end

  def background_css(url)
    "background-image: url(#{url});"
  end
end
