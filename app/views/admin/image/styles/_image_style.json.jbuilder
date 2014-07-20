json.extract! image_style, :id, :title

json.asset_url image_style.asset.custom.url
json.thumbnail_asset_url image_style.asset.thumbnail.url

json.dimensions do
  json.width image_style.width
  json.height image_style.height
end
