json.extract! image, :id, :title, :asset_url
json.thumbnail_asset_url image.asset_url(:thumbnail)
json.dimensions image.transformed_dimensions

if params.fetch(:include_styles, false).to_bool
  json.styles do
    json.array! image.styles do |style|
      json.partial! 'admin/image_styles/image_style', image_style: style
    end
  end
end