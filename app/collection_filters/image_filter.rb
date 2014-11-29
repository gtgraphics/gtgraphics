class ImageFilter < CollectionFilter
  filters :content_type do |images, content_type|
    content_types = Array(content_type).map do |content_type|
      "image/#{content_type.downcase}"
    end
    images.where(content_type: content_types)
  end

  filters :tags, Array[String], coercer: ->(tags) { TagCollection.extract_tags(tags) } do |images, tags|
    images.tagged(tags, case_sensitive: false)
  end
end