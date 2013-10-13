class RemoveActiveFromPageTemplates < ActiveRecord::Migration
  def up
    remove_column :page_templates, :active
  end

  def down
    add_column :page_templates, :active, :boolean, null: false, default: true
  end
end
