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
      project_images << project.project_images.build(image_id: image_id)
      project.save!
    end
  end
end