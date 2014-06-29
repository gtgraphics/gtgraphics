class Admin::TemplatePresenter < Admin::ApplicationPresenter
  presents :template

  self.action_buttons -= [:show]

  def type
    template.type.constantize.model_name.human
  end

  def destroy_path
    h.admin_template_path(template, locale: I18n.locale)
  end

  def edit_path
    h.edit_admin_template_path(template, locale: I18n.locale)
  end

  def template
    object.becomes(Template)
  end
end