class RenameHitsCountOnAttachments < ActiveRecord::Migration
  def change
    rename_column :attachments, :hits_count, :downloads_count
  end
end
