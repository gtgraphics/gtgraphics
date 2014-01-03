class CreateProjectImages < ActiveRecord::Migration
  def change
    create_table :project_images do |t|
      t.belongs_to :project, index: true
      t.belongs_to :image, index: true
      t.integer :position, null: false
    end
  end
end
