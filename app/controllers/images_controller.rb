class ImagesController < PagesController
  embeds :image_page

  before_action :load_image
  attr_reader :image
  helper_method :image

  def show
    respond_to do |format|
      format.html { render_page }
      format.send(@image.format) do
        send_file @image.asset.custom.path, filename: @image.virtual_filename,
                                            content_type: @image.content_type,
                                            disposition: :inline,
                                            x_sendfile: true
      end
    end
  end
  
  def download
    if style_id = params[:style_id]
      @image_style = @image.styles.find_by(position: style_id)
      image = @image_style
    else
      image = @image
    end

    respond_to do |format|
      format.send(image.format) do
        send_file image.asset.custom.path, filename: image.virtual_filename,
                                           content_type: image.content_type,
                                           disposition: :attachment,
                                           x_sendfile: true
      end
    end
  end

  private
  def load_image
    @image = image_page.image
  end
end