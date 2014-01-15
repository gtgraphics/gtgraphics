class ChangeMessages < ActiveRecord::Migration
  def up
    remove_reference :messages, :recipient
    remove_column :messages, :read
    remove_column :messages, :fingerprint
    add_reference :messages, :contact_form
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
