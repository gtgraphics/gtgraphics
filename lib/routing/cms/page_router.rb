class Routing::Cms::PageRouter
  include Singleton

  class << self
    delegate :insert, to: :instance
  end

  def insert(map)
    ::Page::EMBEDDABLE_TYPES.each do |page_type|
      router = "#{page_type.pluralize}Router".constantize.new
      router.insert(map)
    end
  end
end