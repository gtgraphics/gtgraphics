class RenameImageStyleVariations < ActiveRecord::Migration
  def up
    update("UPDATE image_styles SET type = 'Image::Style::Variant' WHERE type = 'Image::Style::Variation'")
  end

  def down
  end
end
