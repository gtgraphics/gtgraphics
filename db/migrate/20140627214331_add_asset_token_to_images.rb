class AddAssetTokenToImages < ActiveRecord::Migration
  def up
    execute "TRUNCATE TABLE images"
    execute "TRUNCATE TABLE image_styles"

    add_column :images, :asset_token, :string, null: false
    add_index :images, :asset_token, unique: true
  end

  def down
    remove_column :images, :asset_token
  end
end
