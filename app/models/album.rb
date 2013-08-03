# == Schema Information
#
# Table name: albums
#
#  id           :integer          not null, primary key
#  slug         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  images_count :integer          default(0), not null
#

class Album < ActiveRecord::Base
  translates :title

  has_many :image_assignments, class_name: 'Album::ImageAssignment', dependent: :destroy
  has_many :images, through: :image_assignments

  validates :slug, presence: true, uniqueness: true
  validates_associated :translations
  
  before_validation :set_slug

  accepts_nested_attributes_for :translations

  def to_param
    slug
  end

  def to_s
    title
  end

  private
  def set_slug
    if slug.blank?
      self.slug = title.parameterize
    else
      self.slug = slug.parameterize
    end
  end
end
