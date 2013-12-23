class HomepagesController < PagesController
  embeds :homepage

  def show
    respond_with_page
  end
end