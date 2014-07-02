module ActionButtonHelper
  def action_buttons_for(object, options = {}, &block)
    displayed_buttons = %i(show edit destroy)
    displayed_buttons &= Array(options.delete(:only)) if options[:only]
    displayed_buttons -= Array(options.delete(:except)) if options[:except]

    capture_haml do
      haml_tag '.btn-toolbar' do
        haml_concat capture(&block) if block_given?
        with_options options.merge(namespace: :admin) do |buttons|
          haml_tag '.btn-group', buttons.view_button_link_for(object) if displayed_buttons.include?(:show)
          haml_tag '.btn-group', buttons.update_button_link_for(object) if displayed_buttons.include?(:edit)
          haml_tag '.btn-group', buttons.destroy_button_link_for(object) if displayed_buttons.include?(:destroy)
        end
      end
    end
  end

  def create_button_link_for(model, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [:new, namespace, parent, model.model_name.singular.to_sym].flatten.compact }
    options[:type] = :success
    icon = options.delete(:icon) { :plus }
    model_name = options.delete(:model) { model.model_name.human }
    caption = options.delete(:caption) { translate('helpers.links.new', model: model_name) }
    button_link_to prepend_icon(icon, caption), url, options
  end

  def destroy_button_link_for(object, options = {})
    options = options.dup
    icon_only = options.delete(:icon_only)
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [namespace, parent, object].flatten.compact }
    model_name = options.delete(:model) { object.class.model_name.human }

    options[:type] = :danger
    options[:method] = :delete
    options[:data] ||= {}
    options[:data][:confirm] = translate('helpers.confirmations.destroy', model: model_name)

    if icon_only
      caption = icon(:trash, outline: true, fixed_width: true)
      options[:class] ||= ""
      options[:class] << " icon-only"
      options[:class].strip!
      options[:title] = translate('helpers.links.destroy', model: object.class.model_name.human)
      options[:data].merge!(toggle: 'tooltip', placement: 'top', container: 'body')
    else
      caption = prepend_icon(:trash, translate('helpers.links.destroy', model: model_name), outline: true)
    end

    button_link_to caption, url, options
  end

  def update_button_link_for(object, options = {})
    options = options.dup
    icon_only = options.delete(:icon_only)
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [:edit, namespace, parent, object].flatten.compact }
    model_name = options.delete(:model) { object.class.model_name.human }

    if icon_only
      caption = icon(:pencil, fixed_width: true)
      options[:class] ||= ""
      options[:class] << " icon-only"
      options[:class].strip!
      options[:title] = translate('helpers.links.edit', model: object.class.model_name.human)
      options[:data] ||= {}
      options[:data].merge!(toggle: 'tooltip', placement: 'top', container: 'body')
    else
      caption = prepend_icon(:pencil, translate('helpers.links.edit', model: model_name))
    end

    button_link_to caption, url, options
  end

  def view_button_link_for(object, options = {})
    options = options.dup
    icon_only = options.delete(:icon_only)
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [namespace, parent, object].flatten.compact }
    model_name = options.delete(:model) { object.class.model_name.human }

    if icon_only
      caption = icon(:info, fixed_width: true)
      options[:class] ||= ""
      options[:class] << " icon-only"
      options[:class].strip!
      options[:title] = translate('helpers.links.view', model: model_name)
      options[:data] ||= {}
      options[:data].merge!(toggle: 'tooltip', placement: 'top', container: 'body')
    else
      caption = prepend_icon(:info, translate('helpers.links.view', model: model_name))
    end

    button_link_to caption, url, options
  end

  # Cancel Button

  def cancel_button(fallback_url, options = {})
    url = request.referer if request.get?
    url ||= fallback_url
    button_link_to translate('helpers.links.cancel'), fallback_url, options
  end
end