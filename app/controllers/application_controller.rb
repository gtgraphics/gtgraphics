class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  if Rails.env.in? %w(production staging)
    rescue_from ActiveRecord::RecordNotFound do
      respond_to do |format|
        format.html { render 'errors/not_found' }
        format.all { head :not_found }
      end
    end
  end
end