class PagesController < ApplicationController
  respond_to :html
  
  def index
  end

  def show
    @page = Page.find_by_path!(params[:id])
    respond_with @page, template: @page.template_path
  end
end