json.extract! image, :id, :title, :width, :height, :transformed_width, :transformed_height
json.url image.asset_url
json.thumbnail_url image.asset_url(:thumbnail)