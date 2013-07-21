module HeadlineHelper
  def index_headline_for(model)
    headline_wrapper_tag do
      content_tag :h1, model.model_name.human(count: 2)
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

  def headline_for(action, model)
    headline_wrapper_tag do
      content_tag :h1, translate(action, scope: 'helpers.titles', model: model.model_name.human)
    end
  end

  private
  def headline_wrapper_tag
    content_tag :div, yield, class: 'page-header clearfix'
  end
end