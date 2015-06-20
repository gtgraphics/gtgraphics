class ErrorsController < ApplicationController
  self.enforce_redirect_to_localized_url = false

  helper_method :status_code, :status, :caught_exception

  def internal_server_error
    respond_with_error
  end

  def not_found
    @suggested_pages = Page.primary.visible

    respond_with_error do |format|
      format.jpeg do
        send_file "#{Rails.root}/app/assets/images/errors/hint.jpg",
                  disposition: :inline
      end
    end
  end

  def unauthorized
    respond_with_error
  end

  def service_unavailable
    respond_with_error
  end

  private

  def status_code
    env.fetch('error.status_code')
  end

  def status
    Router::ErrorHandler::Utils.status_symbol(status_code)
  end

  def caught_exception
    env['action_dispatch.exception']
  end

  def respond_with_error
    respond_to do |format|
      format.html { render status: status }
      yield(format) if block_given?
      format.all { head status }
    end
  end
end
