class HomepagesController < PagesController
  load_embedded :homepage

  def show
    respond_with_page
  end
end