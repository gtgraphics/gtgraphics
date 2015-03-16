class AddTimestampsToUserSocialLinks < ActiveRecord::Migration
  def change
    change_table :user_social_links do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        date = quote(Time.now.to_s(:db))
        update("UPDATE user_social_links SET created_at = #{date}, updated_at = #{date}")
      end
    end
  end
end
