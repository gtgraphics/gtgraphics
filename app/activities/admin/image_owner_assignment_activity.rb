class Admin::ImageOwnerAssignmentActivity < Activity
  embeds_many :images
  embeds_one :author, class_name: 'User'

  validates :image_ids, presence: true, strict: true
  validates :author_id, presence: true

  def perform
    images.update_all(author_id: author_id)
  end
end