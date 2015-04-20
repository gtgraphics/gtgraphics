class Page::ImagesController < Page::ApplicationController
  before_action :load_image
  before_action :load_image_styles, only: :show

  breadcrumbs do |b|
    if action_name.in? %w(buy request_purchase)
      b.append translate('views.images.buy', image: @image.title),
               buy_image_path(@page.path)
    end
  end

  def default
    @parents = @page.ancestors.published.offset(1).to_a
    @gallery_page = @parents.last

    siblings = @page.siblings.published.menu_items.order(:lft)
    @previous_page = siblings.where('lft < ?', @page.lft).last
    @next_page = siblings.where('lft > ?', @page.lft).first

    respond_to do |format|
      format.html { render_page }
      format.send(@image.format) { render_image(@image) }
    end
  end

  alias_method :photo, :default

  def download
    @image_style = @image.styles.find_by!(position: params[:style_id])
    render_image(@image_style, :attachment)
  end

  def buy
    @message = Message::BuyRequest.new
    @message.image = @image

    respond_to do |format|
      format.html { render layout: 'page/contents' }
    end
  end

  def request_purchase
    @message = Message::BuyRequest.new(message_params)
    @message.image = @image
    @message.ip = request.ip

    if @message.suspicious?
      @message.security_question =
        Message::SecurityQuestion.load(flash[:security_question])
    end

    if @message.save
      notification_job = MessageNotificationJob.new(@message.id, I18n.locale)
      Delayed::Job.enqueue(notification_job, queue: 'mailings')

      flash_for @message
      respond_to do |format|
        format.html { redirect_to buy_image_path(@page.path) }
      end
    else
      flash.now.alert = @message.errors[:base].to_sentence
      if @message.suspicious?
        @message.security_question = Message::SecurityQuestion.generate
        flash[:security_question] = @message.security_question.dump
      end
      respond_to do |format|
        format.html { render :buy, layout: 'page/contents' }
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
                                    :sender_email, :body, :security_answer)
  end

  def render_image(image, disposition = :inline)
    path = image.asset.versions[:public].path
    send_file path, filename: image.virtual_filename,
                    content_type: image.content_type,
                    disposition: disposition,
                    x_sendfile: true
  end
end
