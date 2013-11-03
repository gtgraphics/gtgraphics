class CreateRegionDefinitions < ActiveRecord::Migration
  def change
    create_table :region_definitions do |t|
      t.belongs_to :template, index: true
      t.string :label
      t.timestamps
    end
    add_index :region_definitions, :label
    add_index :region_definitions, [:template_id, :label], unique: true
  end
end
