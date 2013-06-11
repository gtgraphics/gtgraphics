json.array!(@pages) do |page|
  json.extract! page, :title, :slug, :content
  json.url page_url(page, format: :json)
end