class CreateRedirections < ActiveRecord::Migration
  def change
    create_table :redirections do |t|
      t.belongs_to :destination_page, index: true
      t.string :destination_url
      t.boolean :external, null: false, default: false
      t.timestamps
    end
    
    reversible do |dir|
      dir.up { Redirection.create_translation_table! title: :string }
      dir.down { Redirection.drop_translation_table! }
    end
  end
end
