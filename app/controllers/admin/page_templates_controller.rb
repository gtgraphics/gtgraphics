class Admin::PageTemplatesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page_template, only: %i(show edit update destroy make_default)

  #breadcrumbs_for_resource :page_templates, class_name: 'Page::Template'

  breadcrumbs do |b|
    b.append Page::Template.model_name.human(count: 2), :admin_page_templates
    b.append translate('breadcrumbs.new', model: Page::Template.model_name.human), :new_admin_page_template if action_name.in? %w(new create)
    b.append @page_template.name, [:admin, @page_template] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Page::Template.model_name.human), [:edit, :admin, @page_template] if action_name.in? %w(edit update)
  end

  def index
    @page_templates = Page::Template.all
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