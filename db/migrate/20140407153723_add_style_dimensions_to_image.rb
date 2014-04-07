class AddStyleDimensionsToImage < ActiveRecord::Migration
  def change
    add_column :images, :predefined_style_dimensions, :text
  end
end
