class PagesController < ApplicationController
  respond_to :html

  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.roots
    respond_with @pages
  end

  def show
    @parent_pages = @page.ancestors
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

  def path_preview
    slug = Sluggable.sanitize_slug(params[:slug].try(:strip))
    parent_page = Page.find(params[:parent_id]) if params[:parent_id].present?
    page = Page.new(parent: parent_page, slug: slug)
    if slug.blank?
      head :ok
    else
      render text: Page.generate_path(page)
    end
  end

  private
  def set_page
    @page = Page.find_by_path!(params[:id])
    #if params[:path]
    #  @page = Page.find_by_path!(params[:path])
    #else
    #  @page = Page.find(params[:id])
    #end
  end

  def page_params
    params.require(:page).permit(:title, :parent_id, :slug, :content)
  end
end
