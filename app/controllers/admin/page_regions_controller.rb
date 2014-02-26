class Admin::PageRegionsController < Admin::ApplicationController
  before_action :load_page
  before_action :load_region

  def show
    respond_to do |format|
      format.html { render text: @region.body }
    end
  end

  def update
    @region.attributes = params[:body]
    if @region.save
      respond_to do |format|
        format.html { render text: @region.body }
      end
    else
      respond_to do |format|
        format.html { head :unprocessable_entity }
      end
    end
  end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end

  def load_region
    region_definition = @page.template.region_definitions.find_by!(label: params[:id])
    @region = @page.regions.find_or_initialize_by(definition: region_definition)
  end
end