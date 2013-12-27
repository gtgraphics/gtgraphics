class RemoveAssetFromImageStyles < ActiveRecord::Migration
  def up
    add_column :image_styles, :preserve_aspect_ratio, :boolean, default: true
    remove_attachment :image_styles, :asset
  end

  def down
    add_attachment :image_styles, :asset
    remove_column :image_styles, :preserve_aspect_ratio
  end
end
