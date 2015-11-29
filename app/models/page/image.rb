# == Schema Information
#
# Table name: image_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  image_id    :integer          not null
#

class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page

    belongs_to :image, class_name: '::Image', inverse_of: :image_pages

    validates :image, presence: true

    delegate :title, to: :image, allow_nil: true
    delegate :format, to: :image

    def previous_sibling
      @previous_sibling ||= begin
        sibling = page.left_sibling
        sibling if sibling.try(:image?)
      end
    end

    def next_sibling
      @next_sibling ||= begin
        sibling = page.right_sibling
        sibling if sibling.try(:image?)
      end
    end

    def to_liquid
      { 'image' => image }
    end

    def to_title
      image.try(:title)
    end
  end
end

require_dependency 'image'
