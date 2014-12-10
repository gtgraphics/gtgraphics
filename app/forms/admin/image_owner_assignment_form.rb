class Admin::ImageOwnerAssignmentForm < Form
  embeds_many :images
  embeds_one :author, class_name: 'User'

  validates :image_ids, presence: true, strict: true
  validates :author_id, presence: true

  def perform
    images.update_all(author_id: author_id)
    Delayed::Job.enqueue(ImageCopyrightAssignmentJob.new(image_ids))
  end
end