class CreateImageFiles < ActiveRecord::Migration
  def change
    create_table :image_files do |t|
      t.belongs_to :image, index: true
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.text :exif_data
      t.timestamps
    end
  end
end
