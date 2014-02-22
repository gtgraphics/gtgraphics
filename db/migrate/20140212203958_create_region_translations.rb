class CreateRegionTranslations < ActiveRecord::Migration
  def up
    remove_column :regions, :concrete_region_id
    remove_column :regions, :concrete_region_type
    rename_table :regions, :page_regions
    
    Page::Region.create_translation_table! body: :text

    rename_table :region_definitions, :template_region_definitions
  end

  def down
    Page::Region.drop_translation_table!
    # The rest is irreversible
  end
end
