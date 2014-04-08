class Admin::TagsController < Admin::ApplicationController
  respond_to :json

  def index
    if params[:query].present?
      @tags = Tag.search(params[:query]).page(params[:page])
    else
      @tags = Tag.popular.limit(10)
    end
    respond_with @tags
  end
end