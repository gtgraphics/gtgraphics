class Admin::MessagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_message, only: %i(show destroy toggle)

  breadcrumbs do |b|
    b.append Message.model_name.human(count: 2), :admin_messages
    b.append 'Archiv', :archived_admin_messages if action_name == 'archived'
  end

  def index
    @messages = current_user.messages.sort(params[:sort], params[:direction])
    respond_with :admin, @messages
  end

  def archived
    @messages = current_user.messages.older_than(2.weeks).sort(params[:sort], params[:direction])
    respond_with :admin, @messages, template: 'admin/messages/index'
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

  private
  def load_message
    @message = current_user.messages.find(params[:id])
  end
end