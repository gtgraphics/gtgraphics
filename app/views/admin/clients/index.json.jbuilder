json.clients do
  json.array! @clients_with_unknown do |client|
    json.partial! 'client', client: client
  end
end
json.page @clients.current_page
json.total_pages @clients.total_pages
json.more !@clients.last_page?