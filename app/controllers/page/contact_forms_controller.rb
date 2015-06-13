class Page::ContactFormsController < Page::ApplicationController
  before_action :load_contact_form

  def show
    @message = @contact_form.messages.new

    respond_with_page
  end

  def send_message
    @message = @contact_form.messages.new(message_params)
    @message.ip = request.ip

    if @message.suspicious?
      @message.security_question =
        Message::SecurityQuestion.load(flash[:security_question])
    end

    if @message.save
      notification_job = MessageNotificationJob.new(@message.id, I18n.locale)
      # Delayed::Job.enqueue(notification_job, queue: 'mailings')
      notification_job.perform

      flash_for @message
      respond_to do |format|
        format.html { redirect_to @page }
      end
    else
      flash.now.alert = @message.errors[:base].to_sentence
      if @message.suspicious?
        @message.security_question = Message::SecurityQuestion.generate
        flash[:security_question] = @message.security_question.dump
      end
      respond_with_page
    end
  end

  private

  def load_contact_form
    @contact_form = @page.embeddable
  end

  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name,
                                    :sender_email, :subject, :body,
                                    :security_answer)
  end
end
