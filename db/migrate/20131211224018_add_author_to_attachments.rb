class AddAuthorToAttachments < ActiveRecord::Migration
  def change
    add_reference :attachments, :author, index: true
  end
end
