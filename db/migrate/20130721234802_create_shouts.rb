class CreateShouts < ActiveRecord::Migration
  def change
    create_table :shouts do |t|
      t.string :nickname
      t.text :message
      t.integer :x, null: false
      t.integer :y, null: false
      t.string :ip
      t.string :user_agent
      t.timestamps
    end
  end
end
