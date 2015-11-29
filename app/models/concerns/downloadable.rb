module Downloadable
  extend ActiveSupport::Concern

  included do
    has_many :downloads, as: :downloadable, dependent: :delete_all
  end

  def track_download!(request)
    Download.create!(downloadable: self) do |download|
      download.referer = request.referer
      download.user_agent = request.user_agent
    end
  end
end
