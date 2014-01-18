class RemoveRegionableFromRegions < ActiveRecord::Migration
  def up
    remove_column :regions, :regionable_id
    remove_column :regions, :regionable_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
