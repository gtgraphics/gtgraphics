class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :type
      t.attachment :screenshot
      t.boolean :default, default: false, null: false
    end
    reversible do |dir|
      dir.up { Template.create_translation_table! name: :string, description: :text }
      dir.down { Template.drop_translation_table! }
    end
  end
end
