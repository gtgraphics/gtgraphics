class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :url
      t.timestamps
    end

    reversible do |dir|
      dir.up { Project.create_translation_table! name: :string, description: :string }
      dir.down { Project.drop_translation_table! }
    end
  end
end
