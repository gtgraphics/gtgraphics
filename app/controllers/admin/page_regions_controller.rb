class Admin::PageRegionsController < Admin::ApplicationController
  before_action :load_page

  rescue_from Template::RegionDefinition::NotFound do |exception|
    respond_to do |format|
      format.html { head :not_found }
    end
  end

  def show
    body = @page.fetch_region(params[:id])
    respond_to do |format|
      format.html { render text: body }
    end
  end

  def update
    label = params[:id]
    previous_body = @page.fetch_region(label)
    @body = params.fetch(:body)
    if @body.present?
      @page.store_region(label, @body)
    else
      @page.remove_region(label)
    end
    if @page.save
      respond_to do |format|
        format.html { render layout: false }
      end
    else
      @body = previous_body
      respond_to do |format|
        format.html { render layout: false, status: :unprocessable_entity }
      end
    end
  end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end