class Routing::Cms::PageRouter
  def self.insert(map)
    ::Page::EMBEDDABLE_TYPES.each do |embeddable_type|
      router = "#{embeddable_type.pluralize}Router".constantize.new(embeddable_type)
      router.insert(map)
    end
  end
end