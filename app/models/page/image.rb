# == Schema Information
#
# Table name: image_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  image_id    :integer
#

class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page

    belongs_to :image, class_name: '::Image'

    validates :image, presence: true

    delegate :title, to: :image, allow_nil: true
    delegate :format, to: :image

    def to_liquid
      { 'image' => image }
    end

    def to_title
      image.title
    end
  end
end
