class RenameAlbumsToGalleries < ActiveRecord::Migration
  def change
    rename_table :albums, :galleries
  end
end
