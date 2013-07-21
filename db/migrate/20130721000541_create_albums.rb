class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :slug, index: true, null: false
      t.timestamps
    end
    reversible do |dir|
      dir.up { Album.create_translation_table! title: :string }
      dir.down { Album.drop_translation_table! }
    end
  end
end
