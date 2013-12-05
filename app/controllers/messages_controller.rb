class MessagesController < ApplicationController
  respond_to :html

  def new
    @message = Message.new
  end

  def create  
    @message = Message.create(message_params)
  end
end