class ImagePageEmbeddingActivity < Activity
  embeds_one :parent_page, class_name: 'Page'
  embeds_one :image

  validate :verify_slug_not_taken, if: -> { parent_page_id.present? }

  def perform
    #image.
  end

  def slug
    image.title(I18n.default_locale).parameterize
  end

  private
  def verify_slug_not_taken
    errors.add(:parent_page_id, :invalid) if parent_page.pages.exists?(slug: slug)
  end
end