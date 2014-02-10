class MessageNotificationMailer < ActionMailer::Base
  def send_notification_email(message, recipient)
    @message = message
    @recipient = recipient
    mail to: @recipient.mail_formatted_name, from: @message.sender, subject: @message.subject
  end
end