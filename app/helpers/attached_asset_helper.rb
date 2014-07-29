module AttachedAssetHelper
  def attached_asset_path(object, version = nil)
    if version.nil?
      url = object.asset.url
    else
      url = object.asset.versions[version.to_sym].url
    end
    timestamp = object.asset_updated_at.to_i
    "#{url}?#{timestamp}"
  end

  def attached_asset_url(object, version = nil)
    path = attached_asset_path(object, version)
    URI.join(root_url, path).to_s
  end
end