class Page < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include PageEmbeddable
    
    belongs_to :page
    belongs_to :template, class_name: 'Template::Content'
  end
end