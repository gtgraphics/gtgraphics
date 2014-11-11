class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :asset_file_name
      t.string :asset_content_type
      t.integer :asset_file_size
      t.datetime :asset_updated_at
      t.timestamps
    end
    
    reversible do |dir|
      dir.up { Attachment.create_translation_table! title: :string, description: :text }
      dir.down { Attachment.drop_translation_table! }
    end
  end
end
