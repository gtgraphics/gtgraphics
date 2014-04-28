module RouteHelper
  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end

  def page_path(*args)
    options = args.extract_options!
    page = args.first
    format = options[:format].try(:to_s)
    options = options.reverse_merge(editing: try(:editing?).presence) if format.nil? or format == 'html'
    if page and page.path.present?
      send("#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
    else
      root_path(options)
    end
  end

  def page_url(*args)
    options = args.extract_options!
    page = args.first
    format = options[:format].try(:to_s)
    options = options.reverse_merge(editing: try(:editing?).presence) if format.nil? or format == 'html'
    if page and page.path.present?
      send("#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
    else
      root_url(options)
    end
  end

  def root_page_path(options = {})
    page_path(options)
  end

  def root_page_url(options = {})
    page_url(options)
  end
end