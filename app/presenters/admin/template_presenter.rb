class Admin::TemplatePresenter < Admin::ApplicationPresenter
  include Admin::MovableResourcePresenter

  presents :template

  self.action_buttons = [:edit, :move_up, :move_down, :destroy]

  def abstract_template
    template.becomes(Template)
  end

  def description
    super.strip.html_safe
  end

  def file_name
    h.content_tag :code, super
  end

  def show_path
    h.admin_template_path(abstract_template, locale: I18n.locale)
  end

  def edit_path
    h.edit_admin_template_path(abstract_template, locale: I18n.locale)
  end

  def type(linked = true)
    h.link_to_if linked, object.class.model_name.human, 
                         h.typed_admin_templates_path(template_type: object.class.model_name.element)
  end

  def usage
    pages_count = template.respond_to?(:pages) ? template.pages.count : 0
    suffix = Page.model_name.human(count: pages_count)
    "#{pages_count} #{suffix}"
  end

  def movable?
    options[:movable].to_b
  end

  def move_down_button(options = {})
    super(options.merge(remote: true)) if movable?
  end

  def move_down_path
    h.move_down_admin_template_path(object)
  end

  def move_up_button(options = {})
    super(options.merge(remote: true)) if movable?
  end

  def move_up_path
    h.move_up_admin_template_path(object)
  end
end