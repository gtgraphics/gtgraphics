class CreateContactFormTranslations < ActiveRecord::Migration
  def up
    ContactForm.create_translation_table! title: :string, description: :text
  end

  def down
    ContactForm.drop_translation_table!
  end
end