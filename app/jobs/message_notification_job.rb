class MessageNotificationJob < Struct.new(:message_id)
  include Job

  self.queue_name = 'notifications'
  self.max_attempts = 0

  def perform
    message = Message.find(message_id)
    message.recipients.each do |recipient|
      MessageNotificationMailer.notification_email(message, recipient).deliver
    end
  end
end