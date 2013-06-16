class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :slug
      t.text :description
      t.timestamps
    end
    add_index :images, :slug, unique: true
  end
end
