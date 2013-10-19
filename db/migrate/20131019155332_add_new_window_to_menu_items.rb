class AddNewWindowToMenuItems < ActiveRecord::Migration
  def change
    add_column :menu_items, :new_window, :boolean, default: false, null: false
  end
end
