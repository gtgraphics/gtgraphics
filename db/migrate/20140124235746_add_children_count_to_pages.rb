class AddChildrenCountToPages < ActiveRecord::Migration
  def up
    add_column :pages, :children_count, :integer, default: 0, null: false
    remove_column :pages, :descendants_count

    Page.connection.schema_cache.clear!
    Page.reset_column_information

    Page.pluck(:id).each do |page_id|
      Page.reset_counters(page_id, :children)
    end
  end

  def down
    remove_column :pages, :children_count
    add_column :pages, :descendants_count, :integer, default: 0, null: false
  end
end
