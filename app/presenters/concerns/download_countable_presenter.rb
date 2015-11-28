module DownloadCountablePresenter
  extend ActiveSupport::Concern

  def downloads_count
    h.number_with_delimiter(super)
  end
end
