class ImagesController < PagesController
  load_embedded :image

  def show
    respond_to do |format|
      format.html { render_page }
      format.send(@image.format) do
        # redirect_to @image.asset.url
        send_file @image.asset.path, content_type: @image.content_type, disposition: :inline, x_sendfile: true
      end
    end
  end
  
  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment, x_sendfile: true
  end
end