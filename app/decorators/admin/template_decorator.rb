class Admin::TemplateDecorator < Admin::ApplicationDecorator
  decorates :template

  def show_path
    h.admin_template_path(template, locale: I18n.locale)
  end

  def edit_path
    h.edit_admin_template_path(template, locale: I18n.locale)
  end
end