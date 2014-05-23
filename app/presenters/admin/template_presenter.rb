class Admin::TemplatePresenter < Admin::ApplicationPresenter
  presents :template

  def type
    template.class.model_name.human
  end

  def show_path
    h.admin_template_path(template, locale: I18n.locale)
  end

  def edit_path
    h.edit_admin_template_path(template, locale: I18n.locale)
  end
end