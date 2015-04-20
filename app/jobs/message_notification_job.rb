class MessageNotificationJob < Struct.new(:message_id, :locale)
  include Job

  self.queue_name = 'notifications'
  self.max_attempts = 0

  def perform
    I18n.with_locale(locale) do
      Message.find(message_id).notify!
    end
  end
end
