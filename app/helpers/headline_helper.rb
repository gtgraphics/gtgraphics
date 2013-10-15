module HeadlineHelper
  HEADLINE_METHOD_CANDIDATES = [:title, :name, :to_s].freeze

  def index_headline_for(model, &block)
    headline model.model_name.human(count: 2), &block
  end

  def create_headline_for(model, &block)
    headline translate('helpers.titles.new', model: model.model_name.human), &block
  end

  def update_headline_for(object, &block)
    model = object.class unless object.is_a? Class
    headline translate('helpers.titles.edit', model: model.model_name.human), &block
  end

  def view_headline_for(object, &block)
    title = HEADLINE_METHOD_CANDIDATES.collect { |method| object.try(method) }.compact.first
    headline title, &block
  end

  def editor_headline_for(object, &block)
    if object.new_record?
      create_headline_for(object.class, &block)
    else
      update_headline_for(object, &block)
    end
  end

  def headline(text, options= {}, &block)
    options[:class] ||= ""
    options[:class] << ' page-header'
    options[:class] << ' page-header-with-content clearfix' if block_given?
    options[:class].strip!
    content_tag(:div, options) do
      html = ""
      html << content_tag(:h1, text, class: block_given? ? 'pull-left' : nil)
      html << content_tag(:div, class: 'page-header-content pull-right', &block) if block_given?
      html.html_safe
    end
  end
end