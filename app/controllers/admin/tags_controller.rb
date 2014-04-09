class Admin::TagsController < Admin::ApplicationController
  respond_to :json

  def index
    if params[:query].present?
      @tags = Tag.search(params[:query])
    else
      @tags = Tag.popular
    end
    @tags = @tags.page(params[:page])
    respond_with @tags
  end
end