# == Schema Information
#
# Table name: project_images
#
#  id         :integer          not null, primary key
#  project_id :integer
#  image_id   :integer
#  position   :integer          not null
#

class Project < ActiveRecord::Base
  class Image < ActiveRecord::Base
    belongs_to :project
    belongs_to :image

    acts_as_list scope: :project_id

    default_scope -> { order(:position) }
  end
end
