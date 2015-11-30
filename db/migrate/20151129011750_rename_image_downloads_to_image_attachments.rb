class RenameImageDownloadsToImageAttachments < ActiveRecord::Migration
  def change
    rename_table :image_downloads, :image_attachments
  end
end
