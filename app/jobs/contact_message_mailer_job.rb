class ContactMessageMailerJob
  include Job

  attr_reader :contact_message

  def initialize(contact_message)
    @contact_message = contact_message
  end

  def perform
    ContactMessageMailer.send_message_email(contact_message).deliver
  end
end