class Page < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include PageEmbeddable
    
    acts_as_page_embeddable template_class: 'Template::Content'
  end
end