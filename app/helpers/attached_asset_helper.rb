module AttachedAssetHelper
  def attached_asset_path(object, version = nil)
    object = object.to_model if object.respond_to?(:to_model)
    if version.nil?
      url = object.asset.url
    else
      url = object.asset.versions.fetch(version.to_sym) do
        fail ArgumentError, "Version not found: #{version}"
      end.url
    end
    timestamp = object.asset_updated_at.to_i
    "#{url}?#{timestamp}"
  end

  def attached_asset_url(object, version = nil)
    path = attached_asset_path(object, version)
    URI.join(root_url, path).to_s
  end
end
