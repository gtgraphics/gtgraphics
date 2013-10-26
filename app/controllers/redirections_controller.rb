class RedirectionsController < PagesController
  before_action :load_redirection

  def show
    redirect_to @redirection.destination, status: @redirection.permanent? ? :moved_permanently : :found
  end

  private
  def load_redirection
    @redirection = @page.embeddable
  end
end