class CreateImageShopLinks < ActiveRecord::Migration
  PROVIDER_MAP = {
    deviantart: 'DeviantArt',
    artflakes: 'Artflakes',
    fineartamerica: 'FineArtAmerica',
    fineartprint: 'FineArtPrint',
    mygall: 'MyGall',
    posterlounge: 'PosterLounge',
    redbubble: 'RedBubble'
  }

  def up
    create_table :image_shop_links do |t|
      t.belongs_to :image, index: true, foreign_key: true
      t.belongs_to :provider, index: true, foreign_key: true
      t.string :url
    end

    PROVIDER_MAP.each do |slug, name|
      provider = select_one <<-SQL
        SELECT id FROM providers
        WHERE name = #{quote(name)}
      SQL
      provider_id = provider['id'] if provider
      provider_id ||= insert <<-SQL
        INSERT INTO providers (name)
        VALUES (#{quote(name)})
      SQL

      images = select_all(<<-SQL).to_a
        SELECT id, shop_urls
        FROM images
      SQL
      images.each do |image|
        image_id = image['id']
        urls = YAML.load(image['shop_urls']) || {}
        url = urls[slug]
        next if url.blank?
        insert <<-SQL
          INSERT INTO image_shop_links (image_id, provider_id, url)
          VALUES (#{image_id}, #{provider_id}, #{quote(url)})
        SQL
      end
    end

    remove_column :images, :shop_urls
  end

  def down
    add_column :images, :shop_urls, :text

    records = select_all(<<-SQL).to_a
      SELECT isls.image_id, isls.provider_id, isls.url,
             providers.name AS provider_name
      FROM image_shop_links AS isls
      INNER JOIN images ON images.id = isls.image_id
      INNER JOIN providers ON providers.id = isls.provider_id
    SQL

    records.each do |record|
      image_id = record['image_id']
      provider_name = record['provider_name']
      provider_slug = PROVIDER_MAP.key(provider_name)
      url = record['url']
      next if provider_slug.blank? || url.blank?

      image = select_one("SELECT shop_urls FROM images WHERE id = #{image_id}")
      urls = YAML.load(image['shop_urls'] || '') || {}
      urls[provider_slug.to_s] = url

      update <<-SQL
        UPDATE images
        SET shop_urls = #{quote(urls.to_yaml)}
        WHERE id = #{image_id}
      SQL
    end

    drop_table :image_shop_links
  end
end
