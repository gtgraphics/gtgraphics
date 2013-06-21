json.array!(@portfolios) do |portfolio|
  json.extract! portfolio, :owner_name
  json.url portfolio_url(portfolio, format: :json)
end