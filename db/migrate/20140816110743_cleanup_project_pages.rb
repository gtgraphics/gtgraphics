class CleanupProjectPages < ActiveRecord::Migration
  def up
    drop_table :project_page_translations

    remove_column :project_pages, :client_name
    remove_column :project_pages, :client_url
    remove_column :project_pages, :released_on
  end 
end
