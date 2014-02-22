class CleanupUnusedTables < ActiveRecord::Migration
  def up
    %w(
      contact_form_translations contact_forms content_translations contents galleries gallery_translations
      page_templates project_translations projects redirection_translations redirections
    ).each do |table_name|
      drop_table table_name rescue nil
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
