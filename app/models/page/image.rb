class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include PageEmbeddable

    belongs_to :image, class_name: '::Image'
  end
end