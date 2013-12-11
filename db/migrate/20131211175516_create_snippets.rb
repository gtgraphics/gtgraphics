class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.belongs_to :author, index: true
      t.timestamps
    end

    reversible do |dir|
      dir.up { Snippet.create_translation_table! name: :string, body: :text }
      dir.down { Snippet.drop_translation_table! }
    end
  end
end
