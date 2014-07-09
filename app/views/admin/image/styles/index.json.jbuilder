json.image_styles do
  json.array! @image_styles, partial: 'image_style', as: :image_style
end
json.page @image_styles.current_page
json.total_pages @image_styles.total_pages
json.more !@image_styles.last_page?
