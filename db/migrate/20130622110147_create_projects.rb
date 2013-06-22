class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.references :portfolio, index: true
      t.text :description
      t.string :client
      t.string :url
      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
