class Admin::Page::RedirectionsController   < Admin::Page::ApplicationController
  before_action :load_redirection

  def edit
    respond_with :admin, @page, @redirection
  end

  def update
    @redirection.attributes = redirection_params
    flash_for @page, :updated if @redirection.save
    respond_with :admin, @page, @redirection, location: :edit_admin_page_contact_form
  end

  private
  def contact_form_params
    params.require(:page_redirection).permit(recipient_ids: []) # TODO
  end

  def load_redirection
    @redirection = @page.embeddable
  end
end