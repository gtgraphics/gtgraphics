class Project::Image < ActiveRecord::Base
  belongs_to :project, inverse_of: :project_images
  belongs_to :image, inverse_of: :project_images

  default_scope -> { order(:position) }
end
