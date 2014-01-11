module ErrorHandlingController
  extend ActiveSupport::Concern

  included do
    unless Rails.env.development?
      rescue_from ActiveRecord::RecordNotFound, with: :render_404
      rescue_from ActionController::UnknownFormat, with: :render_404
    end
  end

  def render_404
    respond_to do |format|
      format.html { render 'public/404', layout: false, status: :not_found }
      format.all { head :not_found }
    end
  end
end