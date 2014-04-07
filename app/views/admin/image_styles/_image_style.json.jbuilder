json.type image_style.type.demodulize.camelize(:lower)
json.id image_style.id if image_style.respond_to?(:id)
json.style_name image_style.style_name if image_style.respond_to?(:style_name)
json.caption image_style.caption
json.dimensions image_style.transformed_dimensions
json.asset_url image_style.asset_url