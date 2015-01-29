class MessageNotificationMailer < ActionMailer::Base
  layout 'admin/mailer'

  helper :attached_asset

  def notification_email(message, recipient)
    @message = message
    @recipient = recipient

    if message.is_a?(Message::BuyRequest)
      subject = translate('views.admin.messages.buy_request_subject',
                          image: message.image).presence
    else
      subject = @message.subject.presence
    end
    subject ||= translate('views.admin.messages.default_subject')

    mail to: @recipient.rfc5322, from: @message.sender, subject: subject
  end
end
