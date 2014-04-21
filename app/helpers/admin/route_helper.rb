module Admin::RouteHelper
  def admin_page_editor_page_path(page, options = {})
    page_path_options = options.delete(:page) { Hash.new }.merge(edit_mode: false)
    send("admin_page_editor_#{page.embeddable_class.model_name.element}_path", options.merge(path: page.path, locale: I18n.locale, page_locale: Page.locale))
  end
end