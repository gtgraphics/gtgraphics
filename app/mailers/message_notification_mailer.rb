class MessageNotificationMailer < ApplicationMailer
  layout 'admin/mailer'

  helper Router::UrlHelpers
  helper :attached_asset

  def notification_email(message)
    @message = message
    @recipients = message.recipients.to_a
    fail 'No recipients found' if @recipients.empty?

    mail to: @recipients.collect(&:rfc5322),
         from: @message.sender,
         reply_to: @message.sender,
         subject: subject_for_message(message)
  end

  private

  def subject_for_message(message)
    if message.is_a?(Message::BuyRequest)
      subject = translate('views.admin.messages.buy_request_subject',
                          image: message.image).presence
    else
      subject = @message.subject.presence
    end
    subject || translate('views.admin.messages.default_subject')
  end
end
