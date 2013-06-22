# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  slug         :string(255)
#  portfolio_id :integer
#  description  :text
#  client       :string(255)
#  url          :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Project < ActiveRecord::Base
  belongs_to :portfolio
  has_many :images, dependent: :destroy

  acts_as_sluggable_on :name

  validates :slug, presence: true, uniqueness: { scope: :portfolio_id }
end
