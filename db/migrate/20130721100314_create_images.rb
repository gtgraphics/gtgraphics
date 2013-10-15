class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :slug, index: { unique: true }, null: false
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.text :exif_data
      t.integer :hits_count, default: 0, null: false
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Image.create_translation_table! caption: :string
      end
      dir.down do
        Image.drop_translation_table!
      end
    end
  end
end
