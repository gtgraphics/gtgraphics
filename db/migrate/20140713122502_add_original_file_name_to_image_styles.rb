class AddOriginalFileNameToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :original_filename, :string
  end
end
