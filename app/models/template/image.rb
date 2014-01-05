class Template < ActiveRecord::Base
  class Image < Template
    self.template_lookup_paths << 'images/templates'
  end
end