class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.belongs_to :record, polymorphic: true, index: true
      t.integer :position
      t.timestamps
    end
    reversible do |dir|
      dir.up { MenuItem.create_translation_table! title: :string }
      dir.down { MenuItem.drop_translation_table! }
    end
  end
end
