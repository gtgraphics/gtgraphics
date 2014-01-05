class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include PageEmbeddable

    belongs_to :page
    belongs_to :template, class_name: 'Template::Image'
    belongs_to :image, class_name: '::Image'
  end
end