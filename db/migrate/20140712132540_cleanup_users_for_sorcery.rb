class CleanupUsersForSorcery < ActiveRecord::Migration
  def up
    User.destroy_all

    remove_column :users, :preferred_locale
    remove_column :users, :email
    remove_column :users, :password_digest
    remove_column :users, :lock_state
    remove_column :users, :locked_until
    remove_column :users, :failed_sign_in_attempts
    remove_column :users, :last_activity_at
    remove_column :users, :last_activity_ip
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_at
    remove_column :users, :last_sign_in_ip
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end