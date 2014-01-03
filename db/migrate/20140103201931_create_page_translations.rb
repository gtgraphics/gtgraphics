class CreatePageTranslations < ActiveRecord::Migration
  def up
    Page.create_translation_table! title: :string, regions: :text, meta_description: :text, meta_keywords: :text
  end

  def down
    Page.drop_translation_table!
  end
end
