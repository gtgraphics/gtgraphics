class ContactMessageMailer < ActionMailer::Base
  default to: %{"GT Graphics" <info@gtgraphics.de>}

  def send_message_email(contact_message)
    @contact_message = contact_message
    mail from: @contact_message.recipient, subject: @contact_message.subject
  end
end