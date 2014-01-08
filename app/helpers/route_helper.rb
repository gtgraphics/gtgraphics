module RouteHelper
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

  def menu_item_target_path(menu_item, options = {})
    target = menu_item.target
    if target.respond_to? :url
      target.url
    else
      polymorphic_path(target, options)
    end
  end
end