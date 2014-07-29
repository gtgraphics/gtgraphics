class AddTypeAndMetaDataToMessages < ActiveRecord::Migration
  def up
    rename_column :messages, :contact_form_id, :delegator_id
    add_column :messages, :type, :string

    update "UPDATE messages SET type = 'Message::Contact'"

    change_column :messages, :type, :string, null: false
    add_index :messages, :type
  end

  def down
    rename_column :messages, :delegator_id, :contact_form_id
    remove_column :messages, :type
  end
end
