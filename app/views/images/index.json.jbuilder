json.array!(@images) do |image|
  json.extract! image, :title, :slug, :description
  json.url image_url(image, format: :json)
end