module Admin::RouteHelper
  def admin_page_editor_page_path(page, options = {})
    send("admin_page_editor_#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path))
  end
end