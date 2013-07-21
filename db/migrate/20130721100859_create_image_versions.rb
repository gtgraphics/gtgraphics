class CreateImageVersions < ActiveRecord::Migration
  def change
    create_table :image_versions do |t|
      t.belongs_to :image, index: true
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.integer :ratio_numerator
      t.integer :ratio_denominator
      t.text :exif_data
      t.timestamps
    end
  end
end
