class Template < ActiveRecord::Base
  class Content < Template
    self.template_lookup_path = 'contents/templates'

    has_many :pages, class_name: 'Page::Content', foreign_key: :template_id, dependent: :destroy
  end
end
