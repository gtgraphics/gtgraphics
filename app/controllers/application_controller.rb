class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :virtual_page_path

  protected
  def virtual_page_path(page)
    "/#{page.path}"
  end
end
