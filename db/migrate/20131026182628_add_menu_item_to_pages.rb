class AddMenuItemToPages < ActiveRecord::Migration
  def change
    add_column :pages, :menu_item, :boolean, null: false, default: true
  end
end
