# == Schema Information
#
# Table name: project_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  project_id  :integer          not null
#

class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page

    belongs_to :project, class_name: '::Project', inverse_of: :project_pages

    validates :image, presence: true

    def to_liquid
      { 'project' => project }
    end

    def to_title
      project.try(:title)
    end
  end
end
