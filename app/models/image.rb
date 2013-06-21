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
  include Sluggable

  acts_as_sluggable_on :title

  validates :title, presence: true

  private
  def set_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end
end
