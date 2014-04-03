# == Schema Information
#
# Table name: tags
#
#  id    :integer          not null, primary key
#  label :string(255)
#

class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :delete_all

  validates :label, presence: true, uniqueness: true
end
