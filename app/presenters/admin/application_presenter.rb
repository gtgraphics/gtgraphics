class Admin::ApplicationPresenter < Presenter
  class_attribute :action_buttons, instance_accessor: false
  self.action_buttons = [:show, :edit, :destroy]

  delegate :to_param, to: :object

  def action_buttons
    h.content_tag :div, class: 'btn-toolbar' do
      self.class.action_buttons.each do |action_button|
        h.concat h.content_tag(:div, send("#{action_button}_button"), class: 'btn-group')
      end
    end
  end

  def action_button_options
    { size: :mini }
  end

  def created_at
    h.time_ago(super)
  end

  def updated_at
    h.time_ago(super)
  end

  def destroyable?
    h.can? :destroy, object
  end

  def editable?
    h.can? :update, object
  end

  def readable?
    h.can? :read, object
  end

  def show_button
    h.button_link_to_if readable?,
                        button_caption(:view, :eye),
                        show_path,
                        action_button_options
  end

  def show_path
    h.polymorphic_path([:admin, object])
  end

  def edit_button
    h.button_link_to_if editable?,
                        button_caption(:edit, :pencil),
                        edit_path,
                        action_button_options
  end

  def edit_path
    h.polymorphic_path([:edit, :admin, object])
  end

  def destroy_button
    confirmation_hint = I18n.translate('helpers.confirmations.destroy', model: object.class.model_name.human)
    h.button_link_to_if destroyable?,
                        button_caption(:destroy, :trash, outline: true),
                        destroy_path,
                        action_button_options.deep_merge(type: :danger, data: { confirm: confirmation_hint })
  end

  def destroy_path
    show_path
  end

  protected
  def button_caption(caption_key, *args)
    icon_options = args.extract_options!.reverse_merge(fixed_width: true)
    icon = args.first
    caption = I18n.translate(caption_key, scope: 'helpers.links', model: object.class.model_name.human)
    h.prepend_icon(icon, caption, icon_options)
  end
end