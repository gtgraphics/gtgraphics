class PagesController < ApplicationController
  respond_to :html

  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.all
    respond_with @pages
  end

  def show
    respond_with @page
  end

  def new
    @page = Page.new
    respond_with @page
  end

  def create
    @page = Page.create(page_params)
    respond_with @page
  end

  def edit
    respond_with @page
  end

  def update
    @page.update(page_params)
    respond_with @page
  end

  def destroy
    @page.destroy
    respond_with @page
  end

  private
  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :slug, :content)
  end
end
