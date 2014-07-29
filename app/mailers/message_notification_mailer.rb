class MessageNotificationMailer < ActionMailer::Base
  layout 'admin/mailer'

  helper :attached_asset
  
  def notification_email(message, recipient)
    @message = message
    @recipient = recipient

    if message.is_a?(Message::BuyRequest)
      subject = I18n.translate('views.admin.messages.buy_request_subject', image: message.image)
    else
      subject = @message.subject
    end

    mail to: @recipient.mail_formatted_name, from: @message.sender, subject: subject
  end
end