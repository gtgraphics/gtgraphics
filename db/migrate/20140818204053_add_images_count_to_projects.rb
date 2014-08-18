class AddImagesCountToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :images_count, :integer, null: false, default: 0

    Project.reset_column_information
    select_all("SELECT id FROM projects").each do |project|
      project_id = project['id']
      Project.reset_counters(project_id, :project_images)
    end
  end

  def down
    remove_column :projects, :images_count
  end
end
