class Admin::Template::RegionDefinitionPresenter < Admin::ApplicationPresenter
  include Admin::MovableResourcePresenter

  presents :region_definition

  self.action_buttons = [:edit, :move_up, :move_down, :destroy]

  def label
    h.content_tag :code, super
  end

  def destroy_path
    h.admin_template_region_definition_path(template, region_definition)
  end

  def edit_path
    h.edit_admin_template_region_definition_path(template, region_definition)
  end

  def move_up_path
    h.move_up_admin_template_region_definition_path(template, region_definition)
  end

  def move_down_path
    h.move_down_admin_template_region_definition_path(template, region_definition)
  end

  protected
  def default_button_options(options = {})
    { icon_only: true }
  end

  private
  def template
    @template ||= region_definition.template
  end

  def icon_button_options(key)
    {
      icon: { caption_html: { class: 'sr-only' } },
      data: { toggle: 'tooltip', placement: 'top', container: 'body' },
      title: I18n.translate(key, scope: 'helpers.links', model: object.class.model_name.human)
    }
  end
end