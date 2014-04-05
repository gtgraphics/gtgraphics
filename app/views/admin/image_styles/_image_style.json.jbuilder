json.extract! image_style, :id, :asset_url, :caption
json.dimensions image_style.transformed_dimensions
json.original_dimensions image_style.dimensions
json.type image_style.type.demodulize.camelize(:lower)