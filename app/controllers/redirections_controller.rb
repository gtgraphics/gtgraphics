class RedirectionsController < PagesController
  before_action :load_redirection

  def show
    status = @redirection.permanent? ? :moved_permanently : :found
    if @redirection.external?
      redirect_to @redirection.destination_url, status: status
    else
      redirect_to page_path(@redirection.destination_page, request.query_parameters), status: status
    end
  end

  private
  def load_redirection
    @redirection = @page.embeddable
  end
end