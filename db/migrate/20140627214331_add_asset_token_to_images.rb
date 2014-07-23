class AddAssetTokenToImages < ActiveRecord::Migration
  def up
    Image.destroy_all

    add_column :images, :asset_token, :string, null: false
    add_index :images, :asset_token, unique: true
  end

  def down
    remove_column :images, :asset_token
  end
end
