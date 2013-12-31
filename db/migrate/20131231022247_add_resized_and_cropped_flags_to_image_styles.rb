class AddResizedAndCroppedFlagsToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :cropped, :boolean, null: false, default: true
    add_column :image_styles, :resized, :boolean, null: false, default: false
  end
end
