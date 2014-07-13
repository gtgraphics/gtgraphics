class AddAssetTokenToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :asset_token, :string
    add_index :image_styles, :asset_token
    add_index :image_styles, [:image_id, :asset_token], unique: true
  end
end
