module ActionButtonHelper
  def action_buttons_for(object, options = {})
    displayed_buttons = %i(show edit destroy)
    displayed_buttons &= Array(options[:only]) if options[:only]
    displayed_buttons -= Array(options[:except]) if options[:except]

    content_tag :div, class: 'btn-toolbar' do
      with_options options.merge(namespace: :admin) do |buttons|
        html = ""
        html << buttons.view_button_link_for(object) if displayed_buttons.include?(:show)
        html << buttons.update_button_link_for(object) if displayed_buttons.include?(:edit)
        html << buttons.destroy_button_link_for(object) if displayed_buttons.include?(:destroy)
        html.html_safe
      end
    end
  end

  def create_button_link_for(model, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [:new, namespace, parent, model.model_name.singular.to_sym].flatten.compact }
    options[:type] = :success
    button_link_to prepend_icon(:plus, translate('helpers.links.new', model: model.model_name.human)), url, options
  end

  def destroy_button_link_for(object, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [namespace, parent, object].flatten.compact }
    options[:type] = :danger
    options[:method] = :delete
    options[:data] ||= {}
    options[:data][:confirm] = translate('helpers.confirm.destroy', model: object.class.model_name.human)
    button_link_to prepend_icon(:remove, translate('helpers.links.destroy', model: object.class.model_name.human)), url, options
  end

  def update_button_link_for(object, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [:edit, namespace, parent, object].flatten.compact }
    button_link_to prepend_icon(:edit, translate('helpers.links.edit', model: object.class.model_name.human)), url, options
  end

  def view_button_link_for(object, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    parent = Array(options.delete(:parent))
    url = options.delete(:url) { [namespace, parent, object].flatten.compact }
    options[:type] = :primary
    button_link_to prepend_icon(:eye_open, translate('helpers.links.view', model: object.class.model_name.human)), url, options
  end
end