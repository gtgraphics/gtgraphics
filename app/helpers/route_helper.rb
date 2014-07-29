module RouteHelper
  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end

  def page_path(*args)
    _page_url(:path, *args)
  end

  def page_url(*args)
    _page_url(:url, *args)
  end

  def root_page_path(options = {})
    page_path(options)
  end

  def root_page_url(options = {})
    page_url(options)
  end

  private
  def _page_url(suffix, *args)
    options = args.extract_options!
    page = args.first
    if page and page.path.present?
      send("#{page.embeddable_class.model_name.element}_#{suffix}", options.merge(path: page.path))
    else
      send("root_#{suffix}", options)
    end
  end
end