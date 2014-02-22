class CleanupUnusedTables < ActiveRecord::Migration
  def up
    %w(contact_forms contents page_templates redirections shouts).each do |table_name|
      drop_table table_name
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
