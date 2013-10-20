# == Schema Information
#
# Table name: templates
#
#  id                      :integer          not null, primary key
#  type                    :string(255)
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  default                 :boolean          default(FALSE), not null
#

class Template < ActiveRecord::Base
  class Content < Template
    def self.template_path
      # TODO
    end
  end
end
