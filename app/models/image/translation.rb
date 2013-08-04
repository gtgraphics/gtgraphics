class Image::Translation < ActiveRecord::Base
  include ::Translation
  
  validates :title, presence: true
end