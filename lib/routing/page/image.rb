class Routing::Page
  class Image < Routing::Page
    def declare
      action :show
      action 'download(/:style_id(/:dimensions))', action: :download, via: :get, as: :download_image
    end
  end
end