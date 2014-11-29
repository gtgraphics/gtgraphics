class RemoveSlugFromTags < ActiveRecord::Migration
  def up
    remove_column :tags, :slug
  end

  def down
    add_column :tags, :slug, :string
    add_index :tags, :slug, unique: true
  end
end
