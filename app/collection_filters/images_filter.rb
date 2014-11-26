class ImagesFilter < CollectionFilter
  filters :content_type

  filters :tags, Array[String], coercer: ->(tags) { TagCollection.extract_tags(tags) } do |images, tags|
    images.tagged(tags, case_sensitive: false)
  end
end