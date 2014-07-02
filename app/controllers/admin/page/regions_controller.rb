class Admin::Page::RegionsController < Admin::Page::ApplicationController
  layout 'admin/page/regions'
  
  before_action do
    @page.check_template_support!
  end

  before_action :load_template
  before_action :load_region_definition, only: %i(edit update destroy)
  before_action :load_region, only: %i(edit update destroy)

  breadcrumbs except: :index do |b|
    b.append Page::Region.model_name.human(count: 2), edit_admin_page_region_path(@page, @region)
  end

  rescue_from ::Template::NotSupported do |error|
    respond_to do |format|
      format.html { redirect_to [:admin, @page], alert: error.message }
      format.any { head :not_found }
    end
  end

  def index
    region_definition = @region_definitions.first
    respond_to do |format|
      format.html do
        if region_definition
          redirect_to edit_admin_page_region_path(@page, region_definition.label)
        else
          redirect_to request.referer || edit_admin_page_path(@page), alert: I18n.translate('views.hints.empty', model: ::Template::RegionDefinition.model_name.human(count: 2))
        end
      end
    end
  end

  def edit
    respond_with :admin, @page, @region
  end

  def update
    @region.attributes = page_region_params
    @region.save
    respond_with :admin, @page, @region, location: edit_admin_page_region_path(@page, @region)
  end

  private
  def load_region_definition
    @region_definition = @template.region_definitions.find_by!(label: params[:id])
  end

  def load_region
    @region = @page.regions.find_or_initialize_by(definition: @region_definition)
  end

  def load_template
    @template = @page.template
    @region_definitions = @template.region_definitions.order(:label)
  end

  def page_region_params
    params.require(:page_region).permit(:body)
  end
end