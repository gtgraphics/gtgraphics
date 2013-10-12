class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @pages = Page.all
    respond_with @pages
  end

  def new
    @page = Page.new
    @page.translations.build(locale: I18n.default_locale)
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
  def page_params
    params.require(:page).permit! # FIXME
  end
end