# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  slug        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Image < ActiveRecord::Base
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_save :set_slug

  private
  def set_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end
end
