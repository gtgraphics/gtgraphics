module ActionButtonHelper
  def create_button_link_for(model, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    url = options.delete(:url) { [:new, namespace, model.model_name.singular.to_sym].flatten.compact }
    options.reverse_merge!(type: :success)
    button_link_to prepend_icon(:plus, translate('helpers.links.new', model: model.model_name.human)), url, options
  end

  def edit_button_link_for(model, options = {})
    options = options.dup
    namespace = options.delete(:namespace)
    url = options.delete(:url) { [:edit, namespace, model.model_name.singular.to_sym].flatten.compact }
    button_link_to prepend_icon(:edit, translate('helpers.links.edit', model: model.model_name.human)), url, options
  end
end