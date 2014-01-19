class AddIndexesToNestedSetColumnsInPages < ActiveRecord::Migration
  def change
    add_index :pages, :lft
    add_index :pages, :rgt
    add_index :pages, :parent_id
    add_index :pages, :depth
  end
end
