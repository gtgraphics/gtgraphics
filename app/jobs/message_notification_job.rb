class MessageNotificationJob < Struct.new(:message_id, :locale)
  include Job

  self.queue_name = 'notifications'
  self.max_attempts = 0

  def perform
    I18n.with_locale(locale) do
      message = Message.find(message_id)
      message.recipients.each do |recipient|
        MessageNotificationMailer.notification_email(message, recipient).deliver
      end
    end
  end
end
