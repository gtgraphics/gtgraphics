class AddFacebookCommentsUriToPageImages < ActiveRecord::Migration
  def up
    add_column :image_pages, :facebook_comments_uri, :string

    pages = select_all <<-SQL.strip_heredoc
      SELECT 
        image_pages.id,
        pages.slug
      FROM 
        image_pages, 
        pages
      WHERE 
        pages.embeddable_id = image_pages.id AND
        pages.embeddable_type = 'Page::Image'
    SQL

    pages.each do |page|
      image_page_id = page['id']
      slug = page['slug']
      uri = quote("http://www.gtgraphics.de/image/#{slug}")

      update <<-SQL.strip_heredoc
        UPDATE image_pages
        SET facebook_comments_uri = #{uri}
        WHERE id = #{image_page_id}
      SQL
    end
  end

  def down
    remove_column :image_pages, :facebook_comments_uri
  end
end
