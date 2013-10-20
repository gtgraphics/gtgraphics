# == Schema Information
#
# Table name: galleries
#
#  id           :integer          not null, primary key
#  slug         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  images_count :integer          default(0), not null
#

class Gallery < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable
  include Templatable

  self.bound_to_page = true

  translates :title

  has_many :image_assignments, class_name: 'Album::ImageAssignment', dependent: :destroy
  has_many :images, through: :image_assignments
  
  before_validation :set_slug

  accepts_nested_attributes_for :translations, allow_destroy: true

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
