class Album < ActiveRecord::Base
  translates :title

  validates :title, presence: true, uniqueness: true
end