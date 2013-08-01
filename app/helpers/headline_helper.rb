module HeadlineHelper
  def index_headline_for(model, &block)
    headline_wrapper_tag class: block_given? ? 'clearfix' : nil do
      html = ""
      html << content_tag(:h1, model.model_name.human(count: 2), class: block_given? ? 'pull-left' : nil)
      html << content_tag(:div, class: 'pull-right', &block) if block_given?
      html.html_safe
    end
  end

  def create_headline_for(model)
    headline_for :new, model
  end

  def update_headline_for(object)
    model = object.class unless object.is_a? Class
    headline_for :edit, model
  end

  def view_headline_for(object)
    headline_wrapper_tag do
      content_tag :h1, object.to_s
    end
  end

  def editor_headline_for(object)
    if object.new_record?
      create_headline_for(object.class)
    else
      update_headline_for(object)
    end
  end

  def headline_for(action, model)
    headline_wrapper_tag do
      content_tag :h1, translate(action, scope: 'helpers.titles', model: model.model_name.human)
    end
  end

  private
  def headline_wrapper_tag(options = {})
    options[:class] ||= ""
    options[:class] << ' page-header clearfix'
    options[:class].strip!
    content_tag :div, yield, options
  end
end