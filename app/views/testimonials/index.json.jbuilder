json.array!(@testimonials) do |testimonial|
  json.extract! testimonial, :name, :slug, :description, :launched_on, :client_name, :url
  json.url testimonial_url(testimonial, format: :json)
end