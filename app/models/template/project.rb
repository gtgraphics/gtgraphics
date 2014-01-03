class Template < ActiveRecord::Base
  class Project < Template
    self.template_lookup_path = 'projects/templates'
  end
end
