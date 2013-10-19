class AddPublishedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :published, :boolean, default: true, null: false
  end
end
