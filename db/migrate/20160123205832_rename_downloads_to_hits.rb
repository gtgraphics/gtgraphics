class RenameDownloadsToHits < ActiveRecord::Migration
  def up
    rename_table :downloads, :hits
    add_column :hits, :type, :string
    add_index :hits, :type
    rename_column :hits, :downloadable_id, :hittable_id
    rename_column :hits, :downloadable_type, :hittable_type
  end

  def down
    delete "DELETE FROM hits WHERE type != 'Download'"
    rename_table :hits, :downloads
    remove_column :downloads, :type
    rename_column :downloads, :hittable_id, :downloadable_id
    rename_column :downloads, :hittable_type, :downloadable_type
  end
end
