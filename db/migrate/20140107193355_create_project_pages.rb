class CreateProjectPages < ActiveRecord::Migration
  def change
    create_table :project_pages do |t|
      t.belongs_to :template, index: true
      t.string :client_name
      t.string :client_url
      t.date :released_on
    end
    reversible do |dir|
      dir.up { Page::Project.create_translation_table! name: :string, description: :text }
      dir.down { Page::Project.drop_translation_table! }
    end
  end
end