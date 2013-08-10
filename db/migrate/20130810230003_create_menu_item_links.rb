class CreateMenuItemLinks < ActiveRecord::Migration
  def change
    create_table :menu_item_links do |t|
      t.string :url
    end
  end
end
