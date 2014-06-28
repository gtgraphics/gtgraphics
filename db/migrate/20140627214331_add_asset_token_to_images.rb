class AddAssetTokenToImages < ActiveRecord::Migration
  def change
    add_column :images, :asset_token, :string, null: false
    add_index :images, :asset_token, unique: true
  end
end
