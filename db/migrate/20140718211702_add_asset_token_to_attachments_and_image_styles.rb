class AddAssetTokenToAttachmentsAndImageStyles < ActiveRecord::Migration
  def change
    add_column :attachments, :asset_token, :string

    select_all("SELECT * FROM attachments").each do |attachment|
      attachment_id = attachment['id']
      asset_token = SecureRandom.uuid
      update("UPDATE attachments SET asset_token = #{quote(asset_token)} WHERE id = #{attachment_id}")
    end
    change_column :attachments, :asset_token, :string, null: false

    change_column :image_styles, :asset_token, :string, null: false
  end

  def down
    remove_column :attachments, :asset_token
  end
end
