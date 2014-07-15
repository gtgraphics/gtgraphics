class Admin::ApplicationPresenter < Presenter
  class_attribute :action_buttons, instance_accessor: false
  self.action_buttons = [:show, :edit, :destroy]

  delegate :to_param, to: :object

  def action_buttons(options = {})
    whitelist = options.delete(:only)
    blacklist = options.delete(:except)

    if whitelist or blacklist
      allowed_actions = []
      allowed_actions += Array(whitelist) if whitelist
      allowed_actions -= Array(blacklist) if blacklist
    else
      allowed_actions = self.class.action_buttons
    end

    h.content_tag :div, class: 'btn-toolbar' do
      allowed_actions.each do |action_button|
        button = send("#{action_button}_button", options)
        h.concat h.content_tag(:div, button, class: 'btn-group')
      end
    end
  end

  # Timestamps

  def created_at
    h.time_ago(super)
  end

  def updated_at
    h.time_ago(super)
  end

  # Privileges

  def destroyable?
    h.can? :destroy, object
  end

  def editable?
    h.can? :update, object
  end

  def readable?
    h.can? :read, object
  end

  # Paths

  def show_path
    h.polymorphic_path([:admin, object])
  end

  def edit_path
    h.polymorphic_path([:edit, :admin, object])
  end

  def destroy_path
    show_path
  end

  # Buttons

  def show_button(options = {})
    button_options = { active: readable?, icon: :eye, caption: :view }
    button :show, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  def edit_button(options = {})
    button :edit, default_button_options(options).deep_merge(options.reverse_merge(active: editable?))
  end

  def destroy_button(options = {})
    button_options = {
      active: destroyable?, method: :delete,
      type: :danger, active: destroyable?, icon: :trash, icon_options: { outline: true },
      data: { confirm: I18n.translate('helpers.confirmations.destroy', model: object.class.model_name.human) }
    }
    button :destroy, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  # Attributes

  def caption_for(attribute)
    object.class.human_attribute_name(attribute)
  end

  def list_item(attribute)
    h.capture do
      h.concat h.content_tag(:dt, caption_for(attribute))
      h.concat h.content_tag(:dd, self.public_send(attribute))
    end
  end

  protected
  def button(type, options = {})
    active = options.delete(:active) { true }
    caption = options.delete(:caption) { type }
    if caption.is_a?(Symbol)
      caption = I18n.translate(caption, scope: 'helpers.links', model: object.class.model_name.human)
    end
    icon_only = options.delete(:icon_only) { false }
    icon_name = options.delete(:icon) { type }
    icon_options = options.delete(:icon_options) { Hash.new }.reverse_merge(fixed_width: true)
    if icon_only
      options.deep_merge!(title: caption, data: { toggle: 'tooltip', placement: 'top', container: 'body' })
    end

    h.button_link_to_if active, send("#{type}_path"), options do
      if icon_name
        icon_options.deep_merge!(caption_html: { class: 'sr-only' }) if icon_only
        h.prepend_icon(icon_name, caption, icon_options)
      else
        caption
      end
    end
  end

  def default_button_options(options = {})
    {}
  end
end