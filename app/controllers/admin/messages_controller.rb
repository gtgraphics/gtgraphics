class Admin::MessagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_message, only: %i(show destroy toggle)

  breadcrumbs do |b|
    b.append Message.model_name.human(count: 2), :admin_messages
    b.append Message.model_name.human, [:admin, @message] if action_name == 'show'
  end

  def index
    @messages = current_user.messages.sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @messages
  end

  def show
    @message.mark_read! if @message.unread?
    respond_with :admin, @message
  end

  def destroy
    @message.destroy
    flash_for @message
    respond_with :admin, @message
  end

  def toggle
    @message.toggle!(:read)
    respond_to do |format|
      format.html { redirect_to request.referer || :admin_messages }
    end
  end

  def destroy_multiple
    message_ids = Array(params[:message_ids])
    Message.destroy_all(id: message_ids)
    flash_for :messages, :destroyed_multiple, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_messages }
    end
  end

  private
  def load_message
    @message = current_user.messages.find(params[:id])
  end
end