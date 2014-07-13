class RemovePredefinedStyleDimensionsFromImages < ActiveRecord::Migration
  def up
    remove_column :images, :predefined_style_dimensions
  end

  def down
    add_column :images, :predefined_style_dimensions, :text
  end
end
