class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.timestamps
    end
    reversible do |dir|
      dir.up { Gallery.create_translation_table! title: :string }
      dir.down { Gallery.drop_translation_table! }
    end
  end
end
