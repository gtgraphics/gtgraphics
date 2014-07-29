class ContactFormsController < PagesController 
  embeds :contact_form

  def show
    @message = contact_form.messages.new
    @message.recipients = @contact_form.recipients
    render_page
  end

  def send_message
    @message = contact_form.messages.new(message_params)
    if @message.save
      notifier_job = MessageNotificationJob.new(@message.id)
      Delayed::Job.enqueue(notifier_job, queue: 'mailings')
      flash_for @message
      respond_to do |format|
        format.html { redirect_to @page }
      end
    else
      render_page
    end
  end

  private
  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name, :sender_email, :subject, :body)
  end
end