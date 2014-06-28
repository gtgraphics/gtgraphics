class AddOriginalFilenameToAttachmentsAndImages < ActiveRecord::Migration
  def change
    add_column :attachments, :original_filename, :string
    add_column :images, :original_filename, :string
  end
end
