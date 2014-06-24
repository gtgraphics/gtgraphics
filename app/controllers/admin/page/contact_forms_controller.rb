class Admin::Page::ContactFormsController < Admin::Page::ApplicationController
  before_action :load_contact_form

  def edit
    respond_with :admin, @page, @contact_form
  end

  def update
    @contact_form.attributes = contact_form_params
    flash_for @page, :updated if @contact_form.save
    respond_with :admin, @page, @contact_form, location: :edit_admin_page_contact_form
  end

  private
  def contact_form_params
    params.require(:page_contact_form).permit(recipient_ids: [])
  end

  def load_contact_form
    @contact_form = @page.embeddable
  end
end