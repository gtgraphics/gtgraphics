class ImagesController < PagesController
  load_embedded :image

  def show
    respond_to do |format|
      format.html { render_page }
      format.send(@image.mime_type.to_sym) do
        send_file @image.asset.path, content_type: @image.content_type, disposition: :inline
      end
    end
  end
  
  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment, x_sendfile: true
  end
end