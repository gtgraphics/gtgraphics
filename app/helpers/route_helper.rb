module RouteHelper
  def about_author_path(author)
    @author_paths ||= {}
    @author_paths[author] ||= begin
      pages = Page.find_by!(path: 'about')
      page = pages.children.find_by!(title: author.name)
      page_path(page)
    end
  end

  def change_locale_path(locale)
    url_for(path: @page.try(:path), locale: locale)
  end

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
    if page.nil? || page.try(:root?)
      public_send("root_#{suffix}", options)
    elsif page.respond_to?(:path)
      public_send("#{page.embeddable_class.model_name.element}_#{suffix}",
                  options.merge(path: page.path))
    else
      root_path = public_send("root_#{suffix}",
                              locale: options.fetch(:locale, I18n.locale))
      path = page.to_s.gsub(/\A\//, '')
      "#{root_path}/#{path}"
    end
  end
end
