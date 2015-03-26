class CreateMessageSenderInfos < ActiveRecord::Migration
  def change
    create_table :message_sender_infos do |t|
      t.string :ip
      t.datetime :created_at
    end

    add_index :message_sender_infos, :ip
    add_index :message_sender_infos, :created_at
  end
end
