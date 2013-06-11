class Image < ActiveRecord::Base
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before :save, :set_slug

  private
  def update_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end
end
