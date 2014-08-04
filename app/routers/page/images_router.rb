class Page::ImagesRouter < Page::ApplicationRouter
  def declare
    super
    get :buy, as: :buy_image
    post :buy, action: :request_purchase, as: :request_image_purchase
    get 'download(/:style_id(/:dimensions))', action: :download, as: :download_image
  end
end