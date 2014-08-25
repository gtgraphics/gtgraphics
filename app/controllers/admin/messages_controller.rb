class Admin::MessagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_message, only: %i(show destroy mark_read mark_unread)

  breadcrumbs do |b|
    b.append Message.model_name.human(count: 2), :admin_messages
    b.append Message.model_name.human, [:admin, @message.becomes(Message)] if action_name == 'show'
  end

  def index
    @message_recipiences = current_user.message_recipiences.eager_load(message: :recipients).uniq
    @message_recipience_search = @message_recipiences.ransack(params[:search])
    @message_recipience_search.sorts = 'message_created_at desc' if @message_recipience_search.sorts.empty?
    @message_recipiences = @message_recipience_search.result.page(params[:page])
    respond_with :admin, @message_recipiences
  end

  def show
    @message_recipience.mark_read!
    respond_with :admin, @message_recipience
  end

  def destroy
    @message_recipience.destroy
    flash_for Message, :destroyed
    respond_with :admin, @message_recipience, location: :admin_messages
  end

  def mark_read
    @message_recipience.mark_read!
    flash_for :message, :marked_read
    respond_to do |format|
      format.html { redirect_to request.referer || :admin_messages }
    end
  end

  def mark_unread
    @message_recipience.mark_unread!
    flash_for :message, :marked_unread
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