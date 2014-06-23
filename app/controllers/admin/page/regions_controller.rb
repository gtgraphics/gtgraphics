class Admin::Page::RegionsController < Admin::ApplicationController
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

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end