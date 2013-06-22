# == Schema Information
#
# Table name: portfolios
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  owner_id    :integer
#  name        :string(255)
#  path        :string(255)
#

class Portfolio < ActiveRecord::Base
  include Sluggable

  acts_as_sluggable_on :name

  belongs_to :owner, class_name: 'User'
  has_many :projects, dependent: :destroy
  has_many :images, through: :projects

  validates :slug, presence: true, uniqueness: { scope: :owner_id }
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
