class AddTargetToMenuItemLinks < ActiveRecord::Migration
  def change
    add_column :menu_items, :target, :string
  end
end
