class RemoveAssetFromImageStyles < ActiveRecord::Migration
  def up
    add_column :image_styles, :preserve_aspect_ratio, :boolean, default: true
    remove_column :image_styles, :asset_file_name
    remove_column :image_styles, :asset_content_type
    remove_column :image_styles, :asset_file_size
    remove_column :image_styles, :asset_updated_at
  end

  def down
    change_table :image_styles do |t|
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at
      t.remove :preserve_aspect_ratio
    end
  end
end
