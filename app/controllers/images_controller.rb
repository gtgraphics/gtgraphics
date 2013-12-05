class ImagesController < PagesController
  load_embedded :image
  
  def download
    render text: "Downloading #{@image} now..."
  end
end