class DownloadsController < ApplicationController
  skip_before_action :set_locale

  def download
    fail NotImplementedError
  end

  private

  def send_attachment(downloadable, disposition)
    downloadable.track_download!(request)

    send_file downloadable.asset.path, filename: downloadable.original_filename,
                                       content_type: downloadable.content_type,
                                       disposition: disposition,
                                       x_sendfile: true
  end
end
