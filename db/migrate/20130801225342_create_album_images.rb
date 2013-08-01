class CreateAlbumImages < ActiveRecord::Migration
  def change
    create_table :album_images do |t|
      t.references :album, index: true, null: false
      t.references :image, index: true, null: false
      t.integer :position, default: 0, null: false
    end
  end
end
