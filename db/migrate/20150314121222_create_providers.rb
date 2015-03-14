class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :logo
      t.datetime :logo_updated_at
      t.string :asset_token
      t.timestamps
    end
  end
end
