class Template < ActiveRecord::Base
  class Content < Template
    self.template_lookup_path = 'contents/templates'
  end
end
