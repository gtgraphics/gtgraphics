class CreateImageStyles < ActiveRecord::Migration
  def change
    create_table :image_styles do |t|
      t.belongs_to :image, index: true
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.timestamps
    end

    reversible do |dir|
      dir.up { Image::Style.create_translation_table! name: :string }
      dir.down { Image::Style.drop_translation_table! }
    end
  end
end
