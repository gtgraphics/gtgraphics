class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include PageEmbeddable

    acts_as_page_embeddable template_class: 'Template::Image'

    belongs_to :image, class_name: '::Image'
  end
end