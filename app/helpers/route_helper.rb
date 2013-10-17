module RouteHelper
  def page_path(page, options = {})
    super(page.path, options)
  end

  def page_url(page, options = {})
    super(page.path, options)
  end

  def menu_item_target_path(menu_item, options = {})
    record = menu_item.record
    if record.respond_to? :url
      menu_item.url
    else
      polymorphic_path(record, options)
    end
  end
end