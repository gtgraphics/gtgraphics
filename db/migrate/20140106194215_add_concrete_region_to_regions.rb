class AddConcreteRegionToRegions < ActiveRecord::Migration
  def change
    rename_column :regions, :regionable_type, :concrete_region_type
    rename_column :regions, :regionable_id, :concrete_region_id
    add_reference :regions, :regionable, polymorphic: true, index: true
  end
end
