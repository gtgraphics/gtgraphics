class Routing::Cms::RouteCache
  include Singleton

  CACHE_KEY = 'cms.routes'

  class << self
    delegate :matches?, :rebuild, :clear, to: :instance
  end

  def initialize
    @cache = Rails.cache
  end

  def matches?(page_type, path)
    entry = @cache.fetch(CACHE_KEY) { collect_paths }
    paths = entry[page_type]
    paths && paths.include?(path)
  end

  def rebuild
    @cache.write(CACHE_KEY, collect_paths)
  end

  def clear
    @cache.delete(CACHE_KEY)
  end

  private
  def collect_paths
    hash = {}
    Page.find_each do |page|
      paths = hash[page.embeddable_type] ||= Set.new
      paths << page.path
    end
    hash
  end
end