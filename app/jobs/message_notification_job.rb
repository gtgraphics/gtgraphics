class MessageNotificationJob < Struct.new(:message_id)
  include Job

  def perform
    message = Message.find(message_id)
    message.recipients.each do |recipient|
      MessageNotificationMailer.send_notification_email(message, recipient).deliver
    end
  end
end