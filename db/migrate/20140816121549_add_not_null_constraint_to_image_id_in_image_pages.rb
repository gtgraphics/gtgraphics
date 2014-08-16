class AddNotNullConstraintToImageIdInImagePages < ActiveRecord::Migration
  def up
    change_column :image_pages, :image_id, :integer, null: false
  end

  def down
    change_column :image_pages, :image_id, :integer, null: true
  end
end
