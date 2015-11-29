module Downloadable
  extend ActiveSupport::Concern

  included do
    has_many :downloads, as: :downloadable, dependent: :delete_all
  end

  def track_download!(attributes = {}, &block)
    Download.create!(downloadable: self) do |download|
      download.attributes = attributes
      yield(download) if block_given?
    end
  end
end
