class Page::HomepagesController < Page::ApplicationController
  def show
    cover_images = ::Image.tagged('Layout').shuffle.includes(:pages)
    @covers = cover_images.each_with_object({}) do |image, covers|
      covers[image] = image.pages.first
    end
    fail 'bla'
    respond_with_page
  end
end
