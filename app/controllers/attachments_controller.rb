class AttachmentsController < ApplicationController
  skip_before_action :set_locale

  def show
    send_attachment :inline
  end

  def download
    send_attachment :attachment
  end

  private

  def send_attachment(disposition)
    attachment = Attachment.find_by!(asset: params[:filename])
    attachment.increment_hits!
    send_file attachment.asset.path, filename: attachment.original_filename,
                                     content_type: attachment.content_type,
                                     disposition: disposition,
                                     x_sendfile: true
  end
end
