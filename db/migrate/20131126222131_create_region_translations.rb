class CreateRegionTranslations < ActiveRecord::Migration
  def up
    Region.create_translation_table! body: :text

    remove_column :regions, :body
  end

  def down
    Region.drop_translation_table!

    add_column :regions, :body, :text
  end
end
