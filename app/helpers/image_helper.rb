module ImageHelper
  def unveiling_image_tag(path, options = {})
    html_options = options.deep_merge(
      class: [*options[:class], 'img-unveiling'].uniq,
      data: { src: asset_path(path) }
    )
    capture do
      concat image_tag(nil, html_options)
      concat content_tag(:noscript, image_tag(path, options))
    end
  end
end
