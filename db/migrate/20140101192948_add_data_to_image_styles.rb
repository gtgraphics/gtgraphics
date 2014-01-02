class AddDataToImageStyles < ActiveRecord::Migration
  def up
    add_column :image_styles, :customization_options, :text
    remove_column :image_styles, :cropped
    remove_column :image_styles, :crop_x
    remove_column :image_styles, :crop_y
    remove_column :image_styles, :crop_width
    remove_column :image_styles, :crop_height
    remove_column :image_styles, :resized
    remove_column :image_styles, :resize_width
    remove_column :image_styles, :resize_height
  end

  def down
    remove_column :image_styles, :customization_options
    add_column :image_styles, :cropped, :boolean
    add_column :image_styles, :crop_x, :integer
    add_column :image_styles, :crop_y, :integer
    add_column :image_styles, :crop_width, :integer
    add_column :image_styles, :crop_height, :integer
    add_column :image_styles, :resized, :boolean
    add_column :image_styles, :resize_width, :integer
    add_column :image_styles, :resize_height, :integer
  end
end
