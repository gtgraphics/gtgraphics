class AttachmentsController < DownloadsController
  before_action :load_attachment

  def show
    if @attachment.image?
      send_attachment @attachment, :inline
    else
      download
    end
  end

  def download
    send_attachment @attachment, :attachment
  end

  private

  def load_attachment
    @attachment = Attachment.find_by!(asset: params[:filename])
  end
end
