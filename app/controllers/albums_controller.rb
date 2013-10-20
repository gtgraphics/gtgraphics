class AlbumsController < PagesController
  before_action :load_album
  
  private
  def load_album
    @album = page.embeddable
  end
end