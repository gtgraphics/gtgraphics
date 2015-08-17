module Social
  module GooglePlusHelper
    def google_plus_like_button(url, options = {})
      options = options.reverse_merge(annotation: nil, size: :medium)
      options[:href] = url
      options[:annotation] = 'none' if options[:annotation] == false
      content_tag :div, nil, class: 'g-plusone', data: options
    end
  end
end
