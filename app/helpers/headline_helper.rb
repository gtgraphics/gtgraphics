module HeadlineHelper
  HEADLINE_METHOD_CANDIDATES = %i(title name to_s).freeze

  def index_headline_for(model, options = {}, &block)
    headline model.model_name.human(count: 2), options, &block
  end

  def create_headline_for(model, options = {}, &block)
    headline translate('helpers.titles.new', model: model.model_name.human), options, &block
  end

  def update_headline_for(object, options = {}, &block)
    model = object.class unless object.is_a? Class
    headline translate('helpers.titles.edit', model: model.model_name.human), options, &block
  end

  def view_headline_for(object, options = {}, &block)
    title = HEADLINE_METHOD_CANDIDATES.collect { |method| object.try(method) }.compact.first
    headline title, options, &block
  end

  def editor_headline_for(object, options = {}, &block)
    if object.new_record?
      create_headline_for(object.class, options, &block)
    else
      update_headline_for(object, options, &block)
    end
  end

  def headline(text, options = {}, &block)
    options[:class] ||= ""
    options[:class] << ' page-header'
    options[:class] << ' page-header-with-content' if block_given?
    options[:class].strip!
    content_tag(:div, options) do
      html = ""
      html << content_tag(:h1, text, class: block_given? ? 'pull-left' : nil)
      html << content_tag(:div, class: 'page-header-content pull-right', &block) if block_given?
      html.html_safe
    end
  end
end