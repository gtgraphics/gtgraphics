class AddHitsCountToImages < ActiveRecord::Migration
  def change
    add_column :images, :hits_count, :integer, default: 0, null: false
  end
end
