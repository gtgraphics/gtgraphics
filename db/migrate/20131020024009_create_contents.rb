class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.timestamps
    end
    reversible do |dir|
      dir.up { Content.create_translation_table! title: :string, content: :text }
      dir.down { Content.drop_translation_table! }
    end
  end
end