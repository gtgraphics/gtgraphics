class Admin::MessagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_message, only: %i(show destroy)

  def index
    @message = current_user.messages
    respond_with :admin, @messages
  end

  def show
    respond_with :admin, @message
  end

  def destroy
    @message.destroy
    flash_for @message
    respond_with :admin, @message
  end

  private
  def load_message
    @message = current_user.messages.find(params[:id])
  end
end