class ChangePages < ActiveRecord::Migration
  def up
    remove_column :pages, :title
    remove_column :pages, :content
    add_column :pages, :template, :string
    add_column :pages, :path, :string
    add_index :pages, :path, unique: true
    
    add_reference :pages, :parent
    add_column :pages, :lft, :integer
    add_column :pages, :rgt, :integer
    add_column :pages, :depth, :integer
  end

  def down
    add_column :pages, :title, :string
    add_column :pages, :content, :text
    remove_column :pages, :template
    remove_column :pages, :path

    remove_reference :pages, :parent
    remove_column :pages, :lft
    remove_column :pages, :rgt
    remove_column :pages, :depth
  end
end
