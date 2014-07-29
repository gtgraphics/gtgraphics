class Routing::Page
  class Image < Routing::Page
    def declare
      action :show
      action :buy, via: :get, as: :buy_image
      action :buy, via: :post, action: :request_purchase, as: :request_image_purchase
      action 'download(/:style_id(/:dimensions))', action: :download, via: :get, as: :download_image
    end
  end
end