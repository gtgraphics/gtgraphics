class Page::ImagesController < Page::ApplicationController
  routes do
    get :buy, as: :buy_image
    post :buy, to: :request_purchase
    get 'download/:style_id(/:dimensions)', to: :download,
                                            as: :download_image
  end

  before_action :load_image
  before_action :load_image_styles, only: :show

  breadcrumbs do |b|
    if action_name.in? %w(buy request_purchase)
      b.append translate('views.images.buy', image: @image.title),
               page_path(@page, :buy_image)
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
      format.send(@image.format) { send_image(@image) }
    end
  end

  alias_method :photo, :default

  def download
    @image_style = @image.styles.find_by!(position: params[:style_id])
    @image_style.increment_counter!(:downloads)

    send_image(@image_style, :attachment)
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
      # Delayed::Job.enqueue(notification_job, queue: 'mailings')
      notification_job.perform

      flash_for @message
      respond_to do |format|
        format.html { redirect_to page_path(@page, :buy_image) }
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

  def send_image(image, disposition = :inline)
    path = image.asset.versions[:public].path
    send_file path, filename: image.virtual_filename,
                    content_type: image.content_type,
                    disposition: disposition,
                    x_sendfile: true
  end
end
