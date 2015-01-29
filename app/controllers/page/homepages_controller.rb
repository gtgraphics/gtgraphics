class Page::HomepagesController < Page::ApplicationController
  def show
    @images = Image.tagged('Layout').limit(5).shuffle
    respond_with_page
  end
end
