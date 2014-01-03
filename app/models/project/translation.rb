class Project < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :name, presence: true
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
