class MessageNotificationJob < Struct.new(:message_id)
  include Job

  def message
    @message ||= Message.find(message_id)
  end

  def perform
    message.recipients.each do |recipient|
      MessageNotificationMailer.send_notification_email(message, recipient).deliver
    end
  end
end