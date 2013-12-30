class CleanupImageStyles < ActiveRecord::Migration
  def up
    remove_column :image_styles, :preserve_aspect_ratio
  end

  def down
    add_column :image_styles, :preserve_aspect_ratio, :boolean, default: true
  end
end
