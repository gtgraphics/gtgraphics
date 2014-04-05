json.records do
  json.array! @image_styles, partial: 'image_style', as: :image_style
end
json.more !@image_styles.last_page?