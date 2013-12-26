class AddCropColumnsToImages < ActiveRecord::Migration
  def change
    add_column :images, :crop_x, :integer
    add_column :images, :crop_y, :integer
    add_column :images, :crop_width, :integer
    add_column :images, :crop_height, :integer
  end
end
