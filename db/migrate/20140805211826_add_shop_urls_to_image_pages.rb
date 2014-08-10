class AddShopUrlsToImagePages < ActiveRecord::Migration
  def up
    add_column :image_pages, :shop_urls, :text

    pages = select_all <<-SQL
      SELECT id, embeddable_id AS image_page_id, metadata
      FROM pages
      WHERE embeddable_type = 'Page::Image'
    SQL

    pages.each do |page|
      page_id = page['id']
      image_page_id = page['image_page_id']
      metadata = page['metadata']
      if metadata.present?
        metadata = YAML.load(metadata)
      else
        metadata = {}
      end

      new_metadata = {}
      shop_urls = {}
      metadata.each do |key, value|
        if key =~ /\A(.*)_url\z/
          shop_urls[$1] = value
        else
          new_metadata[key] = value
        end
      end
      shop_urls = quote(shop_urls.to_yaml)
      new_metadata = quote(new_metadata.to_yaml)

      update "UPDATE pages SET metadata = #{new_metadata} WHERE id = #{page_id}"
      update "UPDATE image_pages SET shop_urls = #{shop_urls} WHERE id = #{image_page_id}"
    end
  end

  def down
    remove_column :image_pages, :shop_urls
  end
end