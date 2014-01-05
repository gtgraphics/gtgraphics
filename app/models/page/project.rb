class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include PageEmbeddable
    include Templatable

    self.template_type = 'Template::Project'

    acts_as_page_embeddable
  end
end