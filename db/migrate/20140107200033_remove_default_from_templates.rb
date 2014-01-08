class RemoveDefaultFromTemplates < ActiveRecord::Migration
  def up
    remove_column :templates, :default
  end

  def down
    add_column :templates, :default, :boolean, default: false, null: false
  end
end
