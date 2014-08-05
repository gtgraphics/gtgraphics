class AddMetadataToPages < ActiveRecord::Migration
  def change
    add_column :pages, :metadata, :text
  end
end
