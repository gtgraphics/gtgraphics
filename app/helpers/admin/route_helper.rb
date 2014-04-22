module Admin::RouteHelper
  def admin_page_editor_path(page, options = {})
    super(options.merge(id: page.to_param).reverse_merge(locale: I18n.locale))
  end

  def admin_page_editor_page_url(page, options = {})
    # TODO
  end
end