class ContactMessageMailerJob < Struct.new(:contact_message)
  include Job

  def perform
    ContactMessageMailer.send_message_email(contact_message).deliver
  end
end