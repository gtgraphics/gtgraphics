class Admin::Page::ContactFormsController < Admin::Page::ApplicationController
  before_action :load_contact_form

  def edit
    
  end

  def update
  end

  private
  def load_contact_form
    @contact_form = @page.embeddable
  end
end