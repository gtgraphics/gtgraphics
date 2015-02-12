class Page::RedirectionsController < Page::ApplicationController
  before_action :load_redirection

  def show
    if @redirection.external?
      destination_uri = URI.parse(@redirection.destination_url)
      destination_query_parameters = Rack::Utils.parse_nested_query(
        destination_uri.query)
      query = request.query_parameters.reverse_merge(
        destination_query_parameters).to_query
      destination_uri.query = query if query.present?
      destination_url = destination_uri.to_s
    else
      destination_url = page_path(@redirection.destination_page,
                                  request.query_parameters)
    end

    respond_to do |format|
      format.html do
        status = @redirection.permanent? ? :moved_permanently : :found
        redirect_to destination_url, status: status
      end
    end
  end

  private

  def load_redirection
    @redirection = @page.embeddable
  end
end
