module RouteHelper
  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end

  def page_path(page, options = {})
    options = options.reverse_merge(locale: Page.locale)
    edit_mode = options.delete(:edit_mode) { try(:editing?) }
    if page.path.present?
      if edit_mode
        admin_page_editor_page_path(page, options)
      else
        send("#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
      end
    else
      root_path(options) # TODO Prefix
    end
  end

  def page_url(page, options = {})
    options = options.reverse_merge(edit_mode: try(:editing?) || false, locale: Page.locale)
    path_method_prefix = "admin_page_editor_" if options.delete(:edit_mode)
    if page.path.present?
      send("#{path_method_prefix}#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
    else
      root_url(options) # TODO Prefix
    end
  end
end