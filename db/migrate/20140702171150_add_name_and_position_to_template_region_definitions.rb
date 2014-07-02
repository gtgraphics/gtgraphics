class AddNameAndPositionToTemplateRegionDefinitions < ActiveRecord::Migration
  def up
    add_column :template_region_definitions, :name, :string
    add_column :template_region_definitions, :position, :integer

    select_all("SELECT * FROM templates").each do |template|
      template_id = template['id']
      sql = <<-SQL.squish
        SELECT * FROM template_region_definitions
        WHERE template_id = #{template_id}
        ORDER BY name
      SQL
      select_all(sql).each_with_index do |region_definition, index|
        region_definition_id = region_definition['id']
        update <<-SQL.squish
          UPDATE template_region_definitions
          SET position = #{index.next}
          WHERE id = #{region_definition_id}
        SQL
      end
    end

    change_column :template_region_definitions, :position, :integer, null: false
  end

  def down
    remove_column :template_region_definitions, :position
    remove_column :template_region_definitions, :name
  end
end
