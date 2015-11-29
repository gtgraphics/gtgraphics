class AttachmentsController < ApplicationController
  skip_before_action :set_locale
  before_action :load_attachment

  def show
    if @attachment.image?
      send_attachment :inline
    else
      download
    end
  end

  def download
    send_attachment :attachment
  end

  private

  def send_attachment(disposition)
    @attachment.track_download!(request)

    send_file @attachment.asset.path, filename: @attachment.original_filename,
                                      content_type: @attachment.content_type,
                                      disposition: disposition,
                                      x_sendfile: true
  end

  def load_attachment
    @attachment = Attachment.find_by!(asset: params[:filename])
  end
end
