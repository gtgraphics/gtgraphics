class AddRegionTypeToTemplateRegionDefinitions < ActiveRecord::Migration
  def change
    add_column :template_region_definitions, :region_type, :string,
               default: 'full'
  end
end
