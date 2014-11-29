class Admin::TagsController < Admin::ApplicationController
  respond_to :json

  def index
    tag_labels = Array(params[:id])
    if tag_labels.any?
      @tags = Tag.where(label: tag_labels)
    else
      if params[:query].present?
        @tags = Tag.search(params[:query])
      else
        @tags = Tag.popular
      end
    end
    @tags = @tags.page(params[:page])
    respond_with @tags
  end
end