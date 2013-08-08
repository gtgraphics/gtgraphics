class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.belongs_to :menu_item_target, polymorphic: true, index: { name: 'index_menu_items_on_menu_item_target' }
      t.integer :parent_id
      t.integer :lft, null: false
      t.integer :rgt, null: false
      t.integer :depth
      t.timestamps
    end
    reversible do |dir|
      dir.up do
        MenuItem.create_translation_table do |t|
          t.string :title
        end
      end
      dir.down do
        MenuItem.drop_translation_table
      end
    end
  end
end