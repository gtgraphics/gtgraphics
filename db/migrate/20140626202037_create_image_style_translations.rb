class CreateImageStyleTranslations < ActiveRecord::Migration
  def up
    Image::Style.create_translation_table! title: :string
  end

  def down
    Image::Style.drop_translation_table!
  end
end
