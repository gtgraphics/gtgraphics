class Image < ActiveRecord::Base
  translates :title, :caption

  has_many :files, class_name: 'ImageFile', dependent: :destroy

  validates :title, presence: true, uniqueness: true

  accepts_nested_attributes_for :files
end