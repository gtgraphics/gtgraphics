class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include PageEmbeddable
    include Templatable

    self.template_type = 'Template::Image'

    belongs_to :image, class_name: '::Image'
  end
end