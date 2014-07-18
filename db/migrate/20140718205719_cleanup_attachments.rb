class CleanupAttachments < ActiveRecord::Migration
  def up
    rename_column :attachments, :asset_file_name, :asset
    rename_column :attachments, :asset_content_type, :content_type
    rename_column :attachments, :asset_file_size, :file_size
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
