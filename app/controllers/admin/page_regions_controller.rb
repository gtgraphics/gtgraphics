class Admin::PageRegionsController < Admin::ApplicationController
  before_action :load_page

  def update
    # TODO
  end

  private
  def load_page
    @page = Page.find(params[:page_id])
  end
end