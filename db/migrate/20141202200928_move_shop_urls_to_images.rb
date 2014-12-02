class MoveShopUrlsToImages < ActiveRecord::Migration
  def up
    add_column :images, :shop_urls, :text

    select_all('SELECT * FROM image_pages').each do |image_page|
      image_id = image_page['image_id']
      shop_urls = quote(image_page['shop_urls'])
      update("UPDATE images SET shop_urls = #{shop_urls} WHERE id = #{image_id}")
    end

    remove_column :image_pages, :shop_urls
  end
end
