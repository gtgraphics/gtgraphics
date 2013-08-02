class AddNestedSetToMenuItems < ActiveRecord::Migration
  def change
    change_table :menu_items do |t|
      t.integer :parent_id
      t.integer :lft, null: false
      t.integer :rgt, null: false
      t.integer :depth
      t.remove :position
    end
  end
end
