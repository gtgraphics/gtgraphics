class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :recipient, index: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :subject
      t.text :body
      t.datetime :created_at
    end
  end
end
