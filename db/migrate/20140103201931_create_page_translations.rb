class CreatePageTranslations < ActiveRecord::Migration
  def up
    remove_column :content_translations, :body
    remove_column :contact_form_translations, :description
    Page.create_translation_table! title: :string, meta_description: :text, meta_keywords: :text
  end

  def down
    add_column :content_translations, :body, :text
    add_column :contact_form_translations, :description, :text
    Page.drop_translation_table!
  end
end
