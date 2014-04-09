json.images do
  json.array! @images, partial: 'image', as: :image
end
json.page @images.current_page
json.total_pages @images.total_pages
json.more !@images.last_page?