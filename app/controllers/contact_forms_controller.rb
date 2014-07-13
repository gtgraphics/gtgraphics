class ContactFormsController < PagesController 
  embeds :contact_form

  def show
    @message = @contact_form.messages.new
    if request.post?
      @message.attributes = message_params
      if @message.save
        notifier_job = MessageNotificationJob.new(@message.id)
        Delayed::Job.enqueue(notifier_job, queue: 'mailings')
        flash_for @message
        respond_to do |format|
          format.html { redirect_to @page }
        end
        return
      end
    end
    render_page
  end

  private
  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name, :sender_email, :subject, :body) # TODO
  end
end