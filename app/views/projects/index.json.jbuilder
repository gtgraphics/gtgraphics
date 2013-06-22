json.array!(@projects) do |project|
  json.extract! project, :name, :slug, :portfolio_id, :description, :client, :url
  json.url project_url(project, format: :json)
end