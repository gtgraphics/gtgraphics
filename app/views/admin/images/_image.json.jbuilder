json.extract! image, :id, :title, :asset_url
json.dimensions image.transformed_dimensions
json.original_dimensions image.dimensions
json.thumbnail_asset_url image.asset_url(:thumbnail)

if params.fetch(:include_custom_styles, false).to_bool
  json.custom_styles do
    json.array! image.custom_styles do |custom_style|
      json.partial! 'admin/image_styles/image_style', image_style: custom_style
    end
  end
end