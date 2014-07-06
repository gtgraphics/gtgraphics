class AddPositionToTemplates < ActiveRecord::Migration
  def up
    add_column :templates, :position, :integer

    Template::TEMPLATE_TYPES.each do |template_type|
      sql = <<-SQL.squish
        SELECT * FROM templates
        WHERE type = #{quote(template_type)}
        ORDER BY id
      SQL
      select_all(sql).each_with_index do |template, index|
        template_id = template['id']
        position = index.next
        update <<-SQL.squish
          UPDATE templates
          SET position = #{position}
          WHERE id = #{template_id}
        SQL
      end
    end

    change_column :templates, :position, :integer, null: false
    # add_index :templates, [:type, :position], unique: true
  end

  def down
    remove_column :templates, :position
  end
end
