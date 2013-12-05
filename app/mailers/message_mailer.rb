class MessageMailer < ActionMailer::Base
  default to: %{"GT Graphics" <info@gtgraphics.de>}

  def send_message_email(message)
    @message = message
    mail from: @message.recipient, subject: @message.subject
  end
end