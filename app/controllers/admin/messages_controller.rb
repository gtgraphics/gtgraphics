class Admin::MessagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_message, only: %i(show destroy toggle)

  breadcrumbs do |b|
    b.append Message.model_name.human(count: 2), :admin_messages
    b.append Message.model_name.human, [:admin, @message] if action_name == 'show'
  end

  def index
    @message_recipiences = current_user.message_recipiences.includes(message: :recipients).references(:messages) \
                                       .sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @message_recipiences
  end

  def show
    @message_recipience.mark_read! if @message_recipience.unread?
    respond_with :admin, @message_recipience
  end

  def destroy
    @message_recipience.destroy
    flash_for Message, :destroyed
    respond_with :admin, @message_recipience, location: :admin_messages
  end

  def toggle
    @message_recipience.toggle!(:read)
    if @message_recipience.read?
      flash_for :message, :marked_read
    else
      flash_for :message, :marked_unread
    end
    respond_to do |format|
      format.html { redirect_to request.referer || :admin_messages }
    end
  end

  def destroy_multiple
    message_ids = Array(params[:message_ids]).reject(&:blank?).map(&:to_i)
    current_user.message_recipiences.joins(:message).where(messages: { id: message_ids }).readonly(false).destroy_all
    flash_for Message, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_messages }
    end
  end

  private
  def load_message
    @message_recipience = current_user.message_recipiences.includes(:message).where(messages: { id: params[:id] }).first!
    @message = @message_recipience.message
  end
end