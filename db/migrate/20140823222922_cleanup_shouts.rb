class CleanupShouts < ActiveRecord::Migration
  def up
    unless table_exists? :shouts
      create_table :shouts do |t|
        t.string :nickname
        t.text :message
        t.integer :x, null: false
        t.integer :y, null: false
        t.string :ip
        t.string :user_agent
        t.timestamps
      end
    end

    add_column :shouts, :star_type, :integer
    remove_column :shouts, :updated_at
  end

  def down
    if table_exists? :shouts
      remove_column :shouts, :star_type
      add_column :shouts, :updated_at, :datetime
    end
  end
end
