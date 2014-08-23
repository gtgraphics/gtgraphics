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
    acts_as_list scope: :project

    belongs_to :project, inverse_of: :project_images, counter_cache: :images_count, touch: true
    belongs_to :image, class_name: '::Image', inverse_of: :project_images

    default_scope -> { order(:position) }
  end
end
