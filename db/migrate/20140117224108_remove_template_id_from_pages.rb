class RemoveTemplateIdFromPages < ActiveRecord::Migration
  def up
    remove_reference :pages, :template
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
