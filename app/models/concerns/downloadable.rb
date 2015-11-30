module Downloadable
  extend ActiveSupport::Concern

  included do
    has_many :downloads, as: :downloadable, dependent: :delete_all
  end

  def track_download!(request = nil)
    Download.create!(downloadable: self) do |download|
      if request
        download.referer = request.referer
        download.user_agent = request.user_agent
      end
    end
  end
end
