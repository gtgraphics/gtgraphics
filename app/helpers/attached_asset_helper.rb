module AttachedAssetHelper
  def attached_asset_path(object, *args)
    options = args.extract_options!.reverse_merge(from: :asset, timestamp: true)
    version = args.first
    object = object.to_model if object.respond_to?(:to_model)
    if version.nil?
      url = object.public_send(options[:from]).url
    else
      url = object.public_send(options[:from]).versions.fetch(version.to_sym) do
        fail ArgumentError, "Version not found: #{version}"
      end.url
    end
    return url unless options[:timestamp]
    return url unless object.respond_to?("#{options[:from]}_updated_at")
    timestamp = object.public_send("#{options[:from]}_updated_at").to_i
    "#{url}?#{timestamp}"
  end

  def attached_asset_url(object, *args)
    path = attached_asset_path(object, *args)
    URI.join(root_url, path).to_s
  end
end
