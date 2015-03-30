class Admin::ProjectImageAssignmentForm < Form
  include Tokenizable

  embeds_one :project
  embeds_many :images

  validates :project, presence: true, strict: true
  validates :image_ids, :image_id_tokens, presence: true

  tokenizes :image_ids

  def project_images
    @project_images ||= []
  end

  def perform
    project_images.clear
    image_ids.each do |image_id|
      project.with_lock do
        project_image = project.project_images.create!(image_id: image_id)
        project_image.update_column(:position, project.project_images.count)
        project_images << project_image
      end
    end
  end
end
