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
    include PageEmbeddable

    acts_as_page_embeddable template_class: 'Template::Image'

    belongs_to :image, class_name: '::Image'

    delegate :title, to: :image, allow_nil: true
    delegate :format, to: :image
  end
end
