class AddIndexableToPages < ActiveRecord::Migration
  def change
    add_column :pages, :indexable, :boolean, default: true, null: false
  end
end
