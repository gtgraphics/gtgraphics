class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :recipient, index: true
      t.string :first_sender_name
      t.string :last_sender_name
      t.string :sender_email
      t.string :subject
      t.text :body
      t.boolean :read, default: false
      t.datetime :created_at
    end
  end
end
