module RouteHelper
  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end

  def page_path(page, options = {})
    options = options.deep_dup
    edit_mode = options.delete(:edit_mode) { try(:editing?) }
    if edit_mode
      editor_locale = options[:editor_locale] || @editor_locale || I18n.locale
      page_locale = options[:locale] || @page_locale || I18n.locale
      admin_page_editor_page_path(page, options.merge(locale: editor_locale, page_locale: page_locale))
    else
      if page.path.present?
        send("#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
      else
        root_path(options) 
      end
    end
  end

  def page_url(page, options = {})
    options = options.deep_dup
    edit_mode = options.delete(:edit_mode) { try(:editing?) }
    if edit_mode
      editor_locale = options[:editor_locale] || @editor_locale || I18n.locale
      page_locale = options[:locale] || @page_locale || I18n.locale
      admin_page_editor_page_url(page, options.merge(locale: editor_locale, page_locale: page_locale))
    else
      if page.path.present?
        send("#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
      else
        root_url(options)
      end
    end
  end
end