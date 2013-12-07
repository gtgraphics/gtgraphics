class ImagesController < PagesController
  load_embedded :image
  
  def download
    send_file @image.asset.path, filename: @image.virtual_file_name, content_type: @image.content_type, disposition: :attachment, x_sendfile: true
  end
end