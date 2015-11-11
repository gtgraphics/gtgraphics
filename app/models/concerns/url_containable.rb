module UrlContainable
  extend ActiveSupport::Concern

  included do
    validates :url, presence: true, url: true

    sanitizes :url, with: :strip

    before_validation :set_default_protocol, if: :url?
  end

  private

  def set_default_protocol
    self.url = "http://#{url}" if url !~ %r{\A(http|https)\://}
  end
end
