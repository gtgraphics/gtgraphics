class AddHitsCountToPagesAndAttachments < ActiveRecord::Migration
  def change
    add_column :pages, :hits_count, :integer, default: 0, null: false
    add_column :attachments, :hits_count, :integer, default: 0, null: false
  end
end
