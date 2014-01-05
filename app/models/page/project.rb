class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include PageEmbeddable
    include Templatable

    belongs_to :template, class_name: 'Template::Project'

    acts_as_page_embeddable
  end
end