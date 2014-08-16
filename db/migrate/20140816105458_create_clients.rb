class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :country, limit: 2
      t.string :website_url
    end
    add_index :clients, :name, unique: true
  end
end
