class IncreaseIpLimitOnMessageSenderInfos < ActiveRecord::Migration
  def up
    change_column :message_sender_infos, :ip, :string, limit: 15
  end
end
