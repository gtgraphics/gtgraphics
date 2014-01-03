class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.date :released_on
      t.timestamps
    end

    reversible do |dir|
      dir.up { Project.create_translation_table! name: :string, description: :string, client_name: :string, client_url: :string }
      dir.down { Project.drop_translation_table! }
    end
  end
end
