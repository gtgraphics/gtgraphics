# == Schema Information
#
# Table name: portfolios
#
#  id          :integer          not null, primary key
#  owner_name  :string(255)
#  slug        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Portfolio < ActiveRecord::Base
  include Sluggable

  acts_as_sluggable_on ->(portfolio) { portfolio.owner.try(:slug) }, unique: true

  belongs_to :owner, class_name: 'User'
  has_many :testimonials, dependent: :destroy
  has_many :images, through: :testimonials

  validates :owner_id, presence: true, uniqueness: true

  def owner_name
    owner.try(:full_name)
  end

  def to_param
    slug
  end

  def to_s
    owner_name
  end
end