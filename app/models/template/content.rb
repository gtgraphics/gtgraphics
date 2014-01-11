class Template < ActiveRecord::Base
  class Content < Template
    self.template_lookup_path = 'contents/templates'

    has_many :content_pages, class_name: 'Page::Content', foreign_key: :template_id, dependent: :destroy
    has_many :pages, through: :content_pages
  end
end
