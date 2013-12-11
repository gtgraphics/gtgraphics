class AddRegionableToRegions < ActiveRecord::Migration
  def change
    add_reference :regions, :regionable, polymorphic: true, index: true
  end
end
