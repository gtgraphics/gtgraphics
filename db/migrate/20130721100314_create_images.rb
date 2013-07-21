class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.timestamps
    end
    reversible do |dir|
      dir.up { Image.create_translation_table! title: :string, caption: :text }
      dir.down { Image.drop_translation_table! }
    end
  end
end
