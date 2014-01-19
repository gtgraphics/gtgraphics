module RouteHelper
  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end
  
  def page_path(page, options = {})
    if page.path.present?
      send("#{page.embeddable_class.model_name.element}_path", page.path, options)
    else
      root_path(options)
    end
  end

  def page_url(page, options = {})
    if page.path.present?
      send("#{page.embeddable_class.model_name.element}_url", page.path, options)
    else
      root_url(options)
    end
  end
end