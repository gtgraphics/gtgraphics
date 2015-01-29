class Page::HomepagesController < Page::ApplicationController
  def show
    @images = Image.tagged('Layout').shuffle.limit(5)
    respond_with_page
  end
end
