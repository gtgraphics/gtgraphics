class AddProjectTypeToProjectTranslations < ActiveRecord::Migration
  def change
    add_column :project_translations, :project_translations, :string
    add_column :project_translations, :project_type, :string
  end
end
