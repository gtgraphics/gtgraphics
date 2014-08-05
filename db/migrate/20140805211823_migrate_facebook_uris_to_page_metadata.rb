class MigrateFacebookUrisToPageMetadata < ActiveRecord::Migration
  def up
    pages = select_all <<-SQL.strip_heredoc
      SELECT 
        pages.id AS id,
        image_pages.facebook_uri
      FROM 
        image_pages, 
        pages
      WHERE 
        pages.embeddable_id = image_pages.id AND
        pages.embeddable_type = 'Page::Image'
    SQL

    pages.each do |page|
      page_id = page['id']
      facebook_uri = page['facebook_uri']

      metadata = {}
      metadata[:facebook_uri] = facebook_uri
      metadata = quote(metadata.to_yaml)

      update <<-SQL.strip_heredoc
        UPDATE pages
        SET metadata = #{metadata}
        WHERE id = #{page_id}
      SQL
    end

    remove_column :image_pages, :facebook_uri
  end

  def down
    add_column :image_pages, :facebook_uri, :string
  end
end
