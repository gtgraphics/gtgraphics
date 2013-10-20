class ImagesController < PagesController
  before_action :load_image
  
  def download
  end

  private
  def load_image
    @image = page.embeddable
  end
end