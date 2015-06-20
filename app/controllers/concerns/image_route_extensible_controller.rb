module ImageRouteExtensibleController
  extend ActiveSupport::Concern

  included do
    helper_method :image_asset_path, :image_asset_url
  end

  def image_asset_path(image, style)
    image.asset.url(style)
  end

  def image_asset_url(image, style)
    request.protocol + request.host_with_port + image_asset_path(image, style)
  end
end
