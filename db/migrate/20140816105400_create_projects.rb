class CreateProjects < ActiveRecord::Migration
  def up
    execute "TRUNCATE TABLE project_pages"
    execute "TRUNCATE TABLE project_page_translations"

    create_table :projects do |t|
      t.references :client, index: true
      t.references :author, index: true
      t.integer :released_in
      t.string :url
      t.timestamps
    end

    Project.create_translation_table! title: :string, description: :text

    add_reference :project_pages, :project, null: false, index: true
  end

  def down
    Project.drop_translation_table!

    drop_table :projects  

    remove_reference :project_pages, :project
  end
end
