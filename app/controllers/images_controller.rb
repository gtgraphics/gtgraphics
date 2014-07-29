class ImagesController < PagesController
  embeds :image_page

  before_action :load_image
  attr_reader :image
  helper_method :image

  breadcrumbs do |b|
    b.append 'Buy', '#' if action_name.in? %w(buy contact)
  end

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
      notifier_job = MessageNotificationJob.new(@message.id)
      Delayed::Job.enqueue(notifier_job, queue: 'mailings')
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
    @image = image_page.image
  end

  def message_params
    params.require(:message).permit(:first_sender_name, :last_sender_name, :sender_email, :body)
  end
end