class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.text :exif_data
      t.timestamps
    end
    reversible do |dir|
      dir.up { Image.create_translation_table! title: :string, description: :text }
      dir.down { Image.drop_translation_table! }
    end
  end
end