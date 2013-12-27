class AddResizeWidthAndHeightToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :resize_width, :integer
    add_column :image_styles, :resize_height, :integer
  end
end
