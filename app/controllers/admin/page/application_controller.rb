class Admin::Page::ApplicationController < Admin::ApplicationController
  respond_to :html
  
  before_action :load_page

  breadcrumbs do |b|
    pages = @page.self_and_ancestors.where.not(parent_id: nil).with_translations_for_current_locale
    pages.each do |page|
      b.append page.title, [:admin, page]
    end
  end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end