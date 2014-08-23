class CleanupShouts < ActiveRecord::Migration
  def up
    add_column :shouts, :star_type, :integer
    remove_column :shouts, :updated_at
  end

  def down
    remove_column :shouts, :star_type
    add_column :shouts, :updated_at, :datetime
  end
end
