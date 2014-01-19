class ContactFormsController < PagesController 
  embeds :contact_form

  def show
    @message = @contact_form.messages.new
    if request.post?
      @message.attributes = message_params
      return redirect_to contact_form_path(@contact_form) if @message.save
    end
    render_page
  end

  private
  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name, :sender_email, :subject, :body) # TODO
  end
end