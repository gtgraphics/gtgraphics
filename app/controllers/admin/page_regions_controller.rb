class Admin::PageRegionsController < Admin::ApplicationController
  before_action :load_page

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { head :not_found }
    end
  end

  def show
    region = @page.regions.labelled(params[:id]).with_translations(I18n.locale).first!
    respond_to do |format|
      format.html { render text: region.body }
    end
  end

  def update
    @page.regions_hash.store(params[:id], params[:body])
    if @page.save
      respond_to do |format|
        format.html { render text: params[:body] }
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
end