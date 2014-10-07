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

  def static_page_path(path, options = {})
    path = "/#{path}" unless path.start_with?('/')
    locale = options.delete(:locale) { I18n.locale }
    uri = URI.parse(path)
    uri.path = "/#{locale}#{uri.path}"
    uri.query = options.to_query.presence
    uri.to_s
  end

  private
  def _page_url(suffix, *args)
    options = args.extract_options!
    page = args.first
    if page.nil? or page.try(:root?)
      self.public_send("root_#{suffix}", options)
    elsif page.respond_to?(:path)
      self.public_send("#{page.embeddable_class.model_name.element}_#{suffix}", options.merge(path: page.path))
    else
      root_path = self.public_send("root_#{suffix}", locale: options.fetch(:locale, I18n.locale))
      path = page.to_s.gsub(/\A\//, '')
      "#{root_path}/#{path}"
    end
  end
end