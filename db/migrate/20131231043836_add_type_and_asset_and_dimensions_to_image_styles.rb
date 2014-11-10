class AddTypeAndAssetAndDimensionsToImageStyles < ActiveRecord::Migration
  def up
    add_column :image_styles, :type, :string
    update "UPDATE image_styles SET type = 'Image::Style::Variation'"
    change_column :image_styles, :type, :string, null: false
    add_index :image_styles, :type

    change_table :image_styles do |t|
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at
      t.integer :width
      t.integer :height
      t.change :cropped, :boolean, null: true
      t.change :resized, :boolean, null: true
    end
  end

  def down
    remove_column :image_styles, :type
    remove_attachment :image_styles, :asset_file_name
    remove_attachment :image_styles, :asset_content_type
    remove_attachment :image_styles, :asset_file_size
    remove_attachment :image_styles, :asset_updated_at
    remove_column :image_styles, :width
    remove_column :image_styles, :height
    # change_column :image_styles, :cropped, :boolean, null: false
    # change_column :image_styles, :cropped, :boolean, null: false
  end
end
