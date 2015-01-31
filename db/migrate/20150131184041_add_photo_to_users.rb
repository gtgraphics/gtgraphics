class AddPhotoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :asset_token, :string

    reversible do |dir|
      dir.up do
        select_all('SELECT * FROM users').each do |user|
          user_id = user['id']
          asset_token = quote(SecureRandom.uuid)
          update <<-SQL
            UPDATE users
            SET asset_token = #{asset_token}
            WHERE id = #{user_id}
          SQL
        end
      end
    end

    add_column :users, :photo, :string
    add_column :users, :photo_updated_at, :datetime
  end
end
