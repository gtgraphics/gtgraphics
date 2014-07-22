json.extract! image, :id, :title

json.asset_url image.asset.custom.url
json.thumbnail_asset_url image.asset.thumbnail.url

json.dimensions do
  json.width image.width
  json.height image.height
end
json.human_dimensions translate(:dimensions, width: image.width, height: image.height)

if params.fetch(:include_styles, false).to_bool
  json.styles do
    json.array! image.styles, partial: 'admin/image/styles/image_style', as: :image_style
  end
else
  json.styles_url admin_image_styles_path(image, format: :json)
end

if params.fetch(:include_tags, false).to_bool
  json.tags do
    json.array! image.tags, partial: 'admin/tags/tag', as: :tag
  end
end