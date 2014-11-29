module Image::ProjectAssignable
  extend ActiveSupport::Concern

  included do
    has_many :project_images, class_name: 'Project::Image', inverse_of: :image, dependent: :destroy
    has_many :projects, through: :project_images, source: :project
  end

  module ClassMethods
    def assigned_to_project
      joins(:project_images).uniq.readonly(false)
    end

    def unassigned_to_project
      where(arel_table[:id].not_in(joins(:project_images).select(Image.arel_table[:id]).ast))
    end
  end
end