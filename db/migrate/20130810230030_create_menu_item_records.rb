class CreateMenuItemRecords < ActiveRecord::Migration
  def change
    create_table :menu_item_records do |t|
      t.references :menu_item_record, polymorphic: true, index: { name: 'index_menu_item_records_on_menu_item_record' }
    end
  end
end
