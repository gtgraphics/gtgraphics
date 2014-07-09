class AddPositionToImageStyles < ActiveRecord::Migration
  def up
    add_column :image_styles, :position, :integer

    select_all("SELECT id FROM images").each do |image|
      image_id = image['id']
      select_all("SELECT * FROM image_styles WHERE image_id = #{image_id} ORDER BY id").each_with_index do |image_style, index|
        style_id = image_style['id']
        update("UPDATE image_styles SET position = #{index.next} WHERE id = #{style_id}")
      end
    end

    change_column :image_styles, :position, :integer, null: false
  end

  def down
    remove_column :image_styles, :position, :integer
  end
end
