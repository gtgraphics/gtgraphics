# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  username   :string(255)
#  slug       :string(255)
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  include Sluggable

  acts_as_sluggable_on :username

  has_one :portfolio

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def to_param
    slug
  end

  def to_s
    full_name
  end
end
