class CreateContentRegionDefinitions < ActiveRecord::Migration
  def change
    create_table :content_region_definitions do |t|
      t.belongs_to :template, index: true
      t.string :label
    end
    add_index :content_region_definitions, :label
    add_index :content_region_definitions, [:template_id, :label], unique: true
  end
end
