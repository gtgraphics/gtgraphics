class Admin::Page::RegionsController < Admin::Page::ApplicationController
  before_action do
    @page.check_template_support!
  end

  before_action :load_template
  before_action :load_region, only: %i(edit update destroy)

  breadcrumbs do |b|
    b.append Page::Region.model_name.human(count: 2), [:admin, @page, :regions]
    if action_name.in? %(edit update)
      b.append translate('breadcrumbs.edit', model: Page::Region.model_name.human), edit_admin_page_region_path(@page, @region)
    end
  end

  rescue_from Template::NotSupported do |error|
    respond_to do |format|
      format.html { redirect_to [:admin, @page], alert: error.message }
      format.any { head :not_found }
    end
  end

  def index
    @region_definitions = @template.region_definitions.order(:label)
    @page_regions = @page.regions.includes(:definition).inject({}) do |regions, region|
      regions.merge!(region.definition => region)
    end
    respond_with :admin, @page, @regions
  end

  def new
    respond_with :admin, @page, @region
  end

  def create
    # TODO
    respond_with :admin, @page, @region
  end

  def edit
    respond_with :admin, @page, @region
  end

  def update
    @region.update(page_region_params)
    respond_with :admin, @page, @region
  end

  def destroy
    @region.destroy
    respond_with :admin, @page, @region
  end

  private
  def load_region
    @region = @page.regions.labelled(params[:id]).first!
  end

  def load_template
    @template = @page.template
  end

  def page_region_params
    params.require(:page_region).permit(:body)
  end
end