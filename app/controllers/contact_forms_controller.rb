class ContactFormsController < PagesController 
  load_embedded :contact_form

  def show
    # TODO Redirect to contact_messages#new
  end

  private
  def contact_message_params
    params.require(:contact_message).permit! # TODO
  end
end