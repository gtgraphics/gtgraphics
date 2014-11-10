class CleanupTemplates < ActiveRecord::Migration
  def up
    remove_column :templates, :screenshot_file_name if column_exists? :templates, :screenshot_file_name
    remove_column :templates, :screenshot_content_type if column_exists? :templates, :screenshot_content_type
    remove_column :templates, :screenshot_file_size if column_exists? :templates, :screenshot_file_size
    remove_column :templates, :screenshot_updated_at if column_exists? :templates, :screenshot_updated_at
    add_column :templates, :name, :string
    add_column :templates, :description, :text

    select_all("SELECT * FROM template_translations WHERE locale = #{quote(I18n.locale.to_s)}").each do |template_translation|
      template_id = template_translation['template_id']
      name = template_translation['name']
      description = template_translation['description']
      update("UPDATE templates SET name = #{quote(name)}, description = #{quote(description)} WHERE id = #{template_id}")
    end

    drop_table :template_translations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
