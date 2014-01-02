class CreateImageStyles < ActiveRecord::Migration
  def change
    create_table :image_styles do |t|
      t.belongs_to :image, index: true
      t.attachment :asset
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end
end
