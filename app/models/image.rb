class Image < ActiveRecord::Base
  translates :title, :caption

  has_many :files, class_name: 'Image::File', dependent: :destroy

  default_scope -> { includes(:files) }

  validates :title, presence: true, uniqueness: true

  accepts_nested_attributes_for :files
end