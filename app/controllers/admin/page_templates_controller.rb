class Admin::PageTemplatesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page_template, only: %i(show edit update destroy make_default)

  #breadcrumbs_for_resource :page_templates, class_name: 'Page::Template'

  def index
    @page_templates = Page::Template.order(:default, :name)
    respond_with :admin, @page_templates
  end

  def new
    @page_template = Page::Template.new
    respond_with :admin, @page_template
  end

  def create
    @page_template = Page::Template.create(page_template_params)
    respond_with :admin, @page_template
  end

  def show
    respond_with :admin, @page_template
  end

  def edit
    respond_with :admin, @page_template
  end

  def update
    @page_template.update(page_template_params)
    respond_with :admin, @page_template
  end

  def destroy
    @page_template.destroy
    respond_with :admin, @page_template
  end

  def make_default
    @page_template.update(default: true)
    respond_with :admin, @page_template, location: :admin_page_templates
  end

  private
  def load_page_template
    @page_template = Page::Template.find(params[:id])
  end

  def page_template_params
    params.require(:page_template).permit(:name, :description, :file_name, :active)
  end
end