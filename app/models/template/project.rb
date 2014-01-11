# == Schema Information
#
# Table name: templates
#
#  id                      :integer          not null, primary key
#  file_name               :string(255)
#  type                    :string(255)
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime
#

class Template < ActiveRecord::Base
  class Project < Template
    self.template_lookup_path = 'projects/templates'

    has_many :project_pages, class_name: 'Page::Project', foreign_key: :template_id, dependent: :destroy
    has_many :pages, through: :project_pages
  end
end
