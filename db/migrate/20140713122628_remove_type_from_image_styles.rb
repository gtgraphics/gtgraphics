class RemoveTypeFromImageStyles < ActiveRecord::Migration
  def up
    remove_column :image_styles, :type
  end

  def down
    add_column :image_styles, :type, :string
    update("UPDATE image_styles SET type = #{quote('Image::Style')}")
    change_column :image_styles, :type, :string, null: false
    add_index :image_styles, :type
  end
end
