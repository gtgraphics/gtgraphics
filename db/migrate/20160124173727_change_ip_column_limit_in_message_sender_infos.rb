class ChangeIpColumnLimitInMessageSenderInfos < ActiveRecord::Migration
  def change
    change_column :message_sender_infos, :ip, :string, limit: 11
  end
end
