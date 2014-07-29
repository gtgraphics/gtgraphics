class AddPermalinkToPages < ActiveRecord::Migration
  def up
    add_column :pages, :permalink, :string

    select_all("SELECT * FROM pages").each do |page|
      page_id = page['id']
      permalink = quote(Page.generate_permalink)
      update("UPDATE pages SET permalink = #{permalink} WHERE id = #{page_id}")
    end

    change_column :pages, :permalink, :string, limit: 6, null: false
    add_index :pages, :permalink, unique: true
  end

  def down
    remove_column :pages, :permalink
  end
end
