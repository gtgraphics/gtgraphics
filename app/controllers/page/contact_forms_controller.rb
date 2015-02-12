class Page::ContactFormsController < Page::ApplicationController
  skip_before_action :force_no_ssl_redirect, if: :live?
  # force_ssl if: :live?

  before_action :load_contact_form

  def show
    @message = @contact_form.messages.new
    respond_with_page
  end

  def send_message
    @message = @contact_form.messages.new(message_params)
    if @message.save
      @message.notify!
      flash_for @message
      respond_to do |format|
        format.html { redirect_to @page }
      end
    else
      respond_with_page
    end
  end

  private

  def load_contact_form
    @contact_form = @page.embeddable
  end

  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name,
                                    :sender_email, :subject, :body)
  end
end
