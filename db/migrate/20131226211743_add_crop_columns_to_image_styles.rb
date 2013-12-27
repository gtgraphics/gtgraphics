class AddCropColumnsToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :crop_x, :integer
    add_column :image_styles, :crop_y, :integer
    rename_column :image_styles, :width, :crop_width
    rename_column :image_styles, :height, :crop_height
  end
end
