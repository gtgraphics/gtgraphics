class Admin::Page::ApplicationController < Admin::ApplicationController
  layout 'admin/page_editor'
  
  respond_to :html
  
  before_action :load_page

  breadcrumbs do |b|
    pages = @page.self_and_ancestors.where.not(parent_id: nil) \
                 .includes(:translations).with_locales(Globalize.fallbacks)
    pages.each do |page|
      b.append page.title, [:admin, page]
    end
    b.append translate('breadcrumbs.edit', model: Page.model_name.human), [:edit, :admin, @page]
  end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end