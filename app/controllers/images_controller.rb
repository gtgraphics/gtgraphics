class ImagesController < PagesController
  embeds :image_page

  before_action :load_image
  attr_reader :image
  helper_method :image

  def show
    respond_to do |format|
      format.html { render_page }
      format.send(@image.format) do
        send_file @image.asset_path, content_type: @image.content_type, disposition: :inline, x_sendfile: true
      end
    end
  end
  
  def download
    if style_id = params[:style_id]
      @image_style = @image.custom_styles.find(style_id)
      asset_path = @image_style.asset_path
      virtual_file_name = @image_style.virtual_file_name
      content_type = @image_style.content_type
      image_format = @image_style.format
    else
      asset_path = @image.asset_path
      virtual_file_name = @image.virtual_file_name
      content_type = @image.content_type
      image_format = @image.format
    end
    respond_to do |format|
      format.send(image_format) do
        send_file asset_path, filename: virtual_file_name, content_type: content_type, disposition: :attachment, x_sendfile: true
      end
    end
  end

  private
  def load_image
    @image = image_page.image
  end
end