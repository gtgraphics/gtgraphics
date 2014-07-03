class Admin::Page::RedirectionsController < Admin::Page::ApplicationController
  before_action :load_redirection

  def edit
    respond_with :admin, @page, @redirection
  end

  def update
    @redirection.attributes = redirection_params
    flash_for @page, :updated if @redirection.save
    respond_with :admin, @page, @redirection, location: :edit_admin_page_redirection
  end

  private
  def redirection_params
    params.require(:page_redirection).permit(:external, :destination_page_id, :destination_url, :permanent)
  end

  def load_redirection
    @redirection = @page.embeddable
  end
end