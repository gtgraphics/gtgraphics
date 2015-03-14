class CreateUserSocialLinks < ActiveRecord::Migration
  def change
    create_table :user_social_links do |t|
      t.belongs_to :user, index: true
      t.belongs_to :provider, index: true
      t.string :url
      t.boolean :shop, null: false, default: false
      t.integer :position
    end
  end
end
