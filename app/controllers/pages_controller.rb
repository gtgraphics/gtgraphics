class PagesController < ApplicationController
  respond_to :html

  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.roots
    respond_with @pages
  end

  def show
    @sub_pages = @page.children
    respond_with @page
  end

  def new
    @page = Page.new(parent_id: params[:parent_id])
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
    if params[:path]
      @page = Page.find_by_path!(params[:path])
    else
      @page = Page.find(params[:id])
    end
  end

  def page_params
    params.require(:page).permit(:title, :parent_id, :slug, :content)
  end
end
