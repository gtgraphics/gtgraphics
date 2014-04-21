module Admin::RouteHelper
  def admin_page_editor_page_path(page, options = {})
    if page.path.present?
      send("admin_page_editor_#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
    else
      admin_page_editor_root_path(options)
    end
  end

  def admin_page_editor_page_url(page, options = {})
    if page.path.present?
      send("admin_page_editor_#{page.embeddable_class.model_name.element}_url", options.merge(path: page.path))
    else
      admin_page_editor_root_url(options)
    end
  end
end