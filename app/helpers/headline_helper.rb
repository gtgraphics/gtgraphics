module HeadlineHelper
  def index_headline_for(model)
    headline_wrapper_tag do
      content_tag :h1, model.model_name.human(count: 2)
    end
  end

  def create_headline_for(model)
    headline_wrapper_tag do
      content_tag :h1, translate('helpers.titles.new', model: model.model_name.human)
    end
  end

  def update_headline_for(model)
    headline_wrapper_tag do
      content_tag :h1, translate('helpers.titles.edit', model: model.model_name.human)
    end
  end

  private
  def headline_wrapper_tag
    content_tag :div, yield, class: 'page-header'
  end
end