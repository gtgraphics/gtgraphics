class CreateMessageRecipiences < ActiveRecord::Migration
  def change
    create_table :message_recipiences do |t|
      t.belongs_to :message, index: true
      t.belongs_to :recipient, index: true
      t.boolean :read, null: false, default: false
    end
  end
end
