class RenameRecordToMenuItemTargetInMenuItems < ActiveRecord::Migration
  def change
    rename_index :menu_items, :index_menu_items_on_record_id_and_record_type, :index_menu_items_on_menu_item_target
    rename_column :menu_items, :record_id, :menu_item_target_id
    rename_column :menu_items, :record_type, :menu_item_target_type
  end
end
