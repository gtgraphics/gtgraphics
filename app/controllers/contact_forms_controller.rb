class ContactFormsController < PagesController 
  embeds :contact_form

  def show
    @message = @contact_form.messages.new
    render_page
  end

  def create
    @message = @contact_form.messages.new(message_params)
    if @message.save
      redirect_to contact_form_path(@contact_form)
    else
      render_page
    end
  end

  private
  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name, :sender_email, :subject, :body) # TODO
  end
end