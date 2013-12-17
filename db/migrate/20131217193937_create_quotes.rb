class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :author
    end

    reversible do |dir|
      dir.up { Quote.create_translation_table! body: :text }
      dir.down { Quote.drop_translation_table! }
    end
  end
end
