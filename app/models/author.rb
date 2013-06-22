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
#  type       :string(255)
#

class Author < User
  has_many :portfolios, foreign_key: :owner_id
end
