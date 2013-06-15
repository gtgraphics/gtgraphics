class Page < ActiveRecord::Base
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_save :set_slug

  private
  def set_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end  
end
