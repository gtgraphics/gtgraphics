json.extract! image, :id, :title, :asset_url
json.thumbnail_asset_url image.asset_url(:thumbnail)
json.dimensions do
  json.width image.width
  json.height image.height
end
json.original_dimensions do
  json.width image.original_width
  json.height image.original_height
end

if params.fetch(:include_styles, false).to_bool
  json.styles do
    json.array! image.styles, partial: 'admin/image_styles/image_style', as: :image_style
  end
end

if params.fetch(:include_tags, false).to_bool
  json.tags do
    json.array! image.tags, partial: 'admin/tags/tag', as: :tag
  end
end