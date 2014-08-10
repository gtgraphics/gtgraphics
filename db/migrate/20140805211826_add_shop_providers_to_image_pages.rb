class AddShopProvidersToImagePages < ActiveRecord::Migration
  def change
    add_column :image_pages, :shop_providers, :text
  end
end