module AttachmentHelper
  def attachment_url(object, version = nil)
    if version.nil?
      url = object.asset.url
    else
      url = object.asset.versions[version.to_sym].url
    end
    timestamp = object.asset_updated_at.to_i
    "#{url}?#{timestamp}"
  end
end