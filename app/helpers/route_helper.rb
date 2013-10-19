module RouteHelper
  def page_path(page, options = {})
    super(page.path, options)
  end

  def page_url(page, options = {})
    super(page.path, options)
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