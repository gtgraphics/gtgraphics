class ContactFormsController < PagesController 
  embeds :contact_form

  def show
    # TODO Redirect to contact_messages#new
    respond_with_page
  end

  private
  def contact_message_params
    params.require(:contact_message).permit! # TODO
  end
end