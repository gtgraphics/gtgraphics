class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.attachment :asset
      t.timestamps
    end
    reversible do |dir|
      dir.up { Attachment.create_translation_table! title: :string, description: :text }
      dir.down { Attachment.drop_translation_table! }
    end
  end
end
