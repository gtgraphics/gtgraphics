class CreateProjectImages < ActiveRecord::Migration
  def change
    create_table :project_images do |t|
      t.references :project, index: true
      t.references :image, index: true
      t.integer :position, null: false
    end
  end
end
