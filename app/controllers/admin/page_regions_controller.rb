class Admin::PageRegionsController < Admin::ApplicationController
  layout 'admin/page_editor'
  
  respond_to :html
  
  before_action :load_page

  breadcrumbs do |b|
    @page.self_and_ancestors.where.not(parent_id: nil).with_translations.each do |page|
      b.append page.title, [:admin, page]
    end
    b.append translate('breadcrumbs.edit', model: Page.model_name.human), [:edit, :admin, @page]
  end


  def index
    @regions = @page.regions
    respond_with :admin, @page, @regions
  end

  # rescue_from Template::RegionDefinition::NotFound do |exception|
  #   respond_to do |format|
  #     format.html { head :not_found }
  #   end
  # end

  # def show
  #   body = @page.fetch_region(params[:id])
  #   respond_to do |format|
  #     format.html { render text: body }
  #   end
  # end

  # def update
  #   label = params[:id]
  #   previous_body = @page.fetch_region(label)
  #   @body = params.fetch(:body)
  #   if @body.present?
  #     @page.store_region(label, @body)
  #   else
  #     @page.remove_region(label)
  #   end
  #   if @page.save
  #     respond_to do |format|
  #       format.html { render layout: false }
  #     end
  #   else
  #     @body = previous_body
  #     respond_to do |format|
  #       format.html { render layout: false, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def update_multiple
  #   respond_to do |format|
  #     format.html { head :ok }
  #   end
  # end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end