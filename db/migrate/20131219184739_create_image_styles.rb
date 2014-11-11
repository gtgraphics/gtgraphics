class CreateImageStyles < ActiveRecord::Migration
  def change
    create_table :image_styles do |t|
      t.belongs_to :image, index: true
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at
      t.integer :width
      t.integer :height
      t.timestamps
    end
  end
end
