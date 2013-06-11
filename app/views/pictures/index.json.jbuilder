json.array!(@pictures) do |picture|
  json.extract! picture, :title, :description
  json.url picture_url(picture, format: :json)
end