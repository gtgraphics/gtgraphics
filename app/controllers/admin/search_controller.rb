class Admin::SearchController < Admin::ApplicationController
  def show
    @search = Admin::Search.new(params[:query])
    respond_to do |format|
      format.json { render json: @search }
    end
  end
end