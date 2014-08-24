class Admin::ImagePageCreationActivity < Admin::MultiplePageCreationActivity
  include Tokenizable

  embeds_many :images

  validates :image_ids, :image_id_tokens, presence: true

  tokenizes :image_ids

  def perform
    create_pages_for :images
  end
end