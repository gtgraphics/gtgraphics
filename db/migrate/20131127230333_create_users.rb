class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :preferred_locale
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps

      # Lockable
      t.string :lock_state, null: false
      t.datetime :locked_until
      t.integer :failed_sign_in_attempts, default: 0, null: false

      # Trackable
      t.datetime :last_activity_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.string :current_sign_in_ip
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip
    end

    add_index :users, :email, unique: true
    add_index :users, :lock_state
  end
end
