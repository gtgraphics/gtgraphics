class CreateHomepageQuotes < ActiveRecord::Migration
  def change
    create_table :homepage_quotes do |t|
      t.string :author
    end
    reversible do |dir|
      dir.up { Homepage::Quote.create_translation_table! body: :text }
      dir.down { Homepage::Quote.drop_translation_table! }
    end
  end
end
