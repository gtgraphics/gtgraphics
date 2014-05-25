class ImageGalleryAssignmentActivity < Activity
  embeds_many :images
  embeds_one :parent_page, class_name: 'Page'

  validates :image_ids, presence: true, strict: true
  validates :parent_page_id, presence: true

  def perform
    # TODO
    raise NotImplementedError
  end
end