class AddSlugToTags < ActiveRecord::Migration
  def up
    add_column :tags, :slug, :string
    add_index :tags, :slug, unique: true

    select_all('SELECT * FROM tags').each do |tag|
      tag_id = tag['id']
      slug = quote(tag['label'].parameterize)
      update("UPDATE tags SET slug = #{slug} WHERE id = #{tag_id}")
    end
  end

  def down
    remove_column :tags, :slug
  end
end
