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
  class ContactForm < Template
    self.template_lookup_path = 'contact_forms/templates'

    has_many :pages, class_name: 'Page::ContactForm', foreign_key: :template_id, dependent: :destroy
  end
end
