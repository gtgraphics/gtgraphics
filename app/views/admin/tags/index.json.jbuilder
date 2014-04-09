json.tags do
  json.array! @tags, partial: 'tag', as: :tag
end
json.page @tags.current_page
json.total_pages @tags.total_pages
json.more !@tags.last_page?
