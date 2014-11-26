class ImagesFilter < CollectionFilter
  filters :content_type

  filters :tags, Array[String] do |images, name, tags|
    images.tagged(tags)
  end
end