class MessageMailerJob
  include Job

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def perform
    MessageMailer.send_message_email(message).deliver
  end
end