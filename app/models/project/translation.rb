# == Schema Information
#
# Table name: project_translations
#
#  id          :integer          not null, primary key
#  project_id  :integer          not null
#  locale      :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :string(255)
#  client_name :string(255)
#  client_url  :string(255)
#

class Project < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :name, presence: true
    validates :client_name, presence: true
    validates :client_url, url: true, allow_blank: true

    before_validation :sanitize_client_url

    private
    def sanitize_client_url
      if client_url.present? and client_url !~ /\A(http|https):\/\//i
        self.client_url = 'http://' + client_url
      end
    end
  end
end
