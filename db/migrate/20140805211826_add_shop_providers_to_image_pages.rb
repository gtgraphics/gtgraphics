class AddShopProvidersToImagePages < ActiveRecord::Migration
  def up
    add_column :image_pages, :shop_providers, :text

    pages = select_all "SELECT id, metadata FROM pages"
    pages.each do |page|
      page_id = page['id']
      metadata = YAML.load(page['metadata'])

      new_metadata = {}
      shop_providers = {}
      metadata.each do |key, value|
        if key =~ /\A(.*)_url\z/
          shop_providers[$1] = value
        else
          new_metadata[key] = value
        end
      end
      shop_providers = quote(shop_providers.to_yaml)
      new_metadata = quote(new_metadata.to_yaml)

      update "UPDATE pages SET metadata = #{new_metadata} WHERE id = #{page_id}"
      update "UPDATE image_pages SET shop_providers = #{shop_providers} WHERE page_id = #{page_id}"
    end
  end

  def down
    remove_column :image_pages, :shop_providers
  end
end