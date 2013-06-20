json.array!(@redirections) do |redirection|
  json.extract! redirection, :source_path, :destination_url
  json.url redirection_url(redirection, format: :json)
end