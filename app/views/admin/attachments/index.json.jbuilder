json.attachments do
  json.array! @attachments, partial: 'attachment', as: :attachment
end
json.page @attachments.current_page
json.total_pages @attachments.total_pages
json.more !@attachments.last_page?
