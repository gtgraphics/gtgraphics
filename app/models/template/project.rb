class Template < ActiveRecord::Base
  class Project < Template
    self.template_lookup_paths << 'projects/templates'
  end
end