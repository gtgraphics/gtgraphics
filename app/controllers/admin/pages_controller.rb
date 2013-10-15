class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @pages = Page.all
    respond_with :admin, @pages
  end

  def new
    @page = Page.new(parent_id: params[:parent_id])
    @page.translations.build(locale: I18n.default_locale)
    respond_with :admin, @page
  end

  def create
    @page = Page.create(page_params)
    respond_with :admin, @page
  end

  def show
    respond_with :admin, @page
  end

  def edit
    respond_with :admin, @page
  end

  def update
    @page.update(page_params)
    respond_with :admin, @page
  end

  def destroy
    @page.destroy
    respond_with :admin, @page
  end

  def preview_path
    @page = Page.new(params.symbolize_keys.slice(:slug, :parent_id))
    @page.valid?
    respond_to do |format|
      format.html { render text: File.join(request.host, @page.path) }
    end
  end

  private
  def load_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit! # FIXME
  end
end