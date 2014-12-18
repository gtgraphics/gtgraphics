class Page::ImagesController < Page::ApplicationController
  before_action :load_image
  before_action :load_image_styles, only: :show

  breadcrumbs do |b|
    b.append 'Buy', '#' if action_name.in? %w(buy request_purchase)
  end

  def default
    @gallery_page = @page.parent
    @previous_page = @page.left_sibling || @page.siblings.last
    @next_page = @page.right_sibling || @page.siblings.first

    respond_to do |format|
      format.html { render_page }
      format.send(@image.format) { render_image(@image) }
    end
  end

  def download
    style_id = params[:style_id]
    if style_id
      @image_style = @image.styles.find_by!(position: style_id)
      image = @image_style
    else
      image = @image
    end

    render_image(image, :attachment)
  end

  def buy
    @message = Message::BuyRequest.new
    @message.image = @image
    respond_to do |format|
      format.html
    end
  end

  def request_purchase
    @message = Message::BuyRequest.new(message_params)
    @message.image = @image
    if @message.save
      @message.notify!
      flash_for @message
      respond_to do |format|
        format.html { redirect_to @page }
      end
    else
      respond_to do |format|
        format.html { render :buy }
      end
    end
  end

  private

  def load_image
    @image = @page.embeddable.image
  end

  def load_image_styles
    @image_styles = @image.styles.with_translations_for_current_locale
  end

  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name,
                                    :sender_email, :body)
  end

  def render_image(image, disposition = :inline)
    send_file image.asset.custom.path, filename: image.virtual_filename,
                                       content_type: image.content_type,
                                       disposition: disposition,
                                       x_sendfile: true
  end
end
