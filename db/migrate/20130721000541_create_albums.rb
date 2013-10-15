class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :slug, index: true, null: false
      t.integer :images_count, default: 0, null: false
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Album.create_translation_table! title: :string
      end
      dir.down do
        Album.drop_translation_table!
      end
    end
  end
end
