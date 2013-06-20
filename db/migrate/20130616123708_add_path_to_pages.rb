class AddPathToPages < ActiveRecord::Migration
  def change
    add_column :pages, :path, :string
    add_index :pages, :path, unique: true
  end
end
