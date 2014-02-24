module RouteHelper
  def edit_page_path(page, options = {})
    if page.path.present?
      send("edit_#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
    else
      edit_root_path(options) # TODO
    end
  end

  def edit_page_url(page, options = {})
    if page.path.present?
      send("edit_#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
    else
      edit_root_url(options) # TODO
    end
  end

  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end
  
  def page_path(page, options = {})
    if options.delete(:edit_mode) { try(:editing?) }
      edit_page_path(page, options)
    else
      show_page_path(page, options)
    end
  end

  def page_url(page, options = {})
    if options.delete(:edit_mode) { try(:editing?) }
      edit_page_url(page, options)
    else
      show_page_url(page, options)
    end
  end

  def show_page_path(page, options = {})
    if page.path.present?
      send("#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
    else
      root_path(options)
    end
  end

  def show_page_url(page, options = {})
    if page.path.present?
      send("#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
    else
      root_url(options)
    end
  end
end