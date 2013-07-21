class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_controller_context

  private
  def set_controller_context
    RequestStore.store[:controller_context] = self
  end
end
