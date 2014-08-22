if client.is_a?(Client)
  json.id client.name
  json.known true
else
  json.id client
  json.known false
end