class RemoveBodyFromPageRegions < ActiveRecord::Migration
  def up
    remove_column :page_regions, :body
  end

  def down
    add_column :page_regions, :body, :text
  end
end
