class Routing::Cms::RouteCache
  include Singleton

  CACHE_KEY = 'cms.routes'

  class << self
    delegate :entries, :matches?, :rebuild, :clear, to: :instance
    delegate :page_type_for_path, :root_page_type, to: :instance
  end

  def initialize
    @cache = Rails.cache
  end

  def entries
    @cache.fetch(CACHE_KEY) { collect_paths }
  end

  def matches?(page_type, path)
    paths = self.entries[page_type]
    paths && paths.include?(path)
  end

  def rebuild
    @cache.write(CACHE_KEY, collect_paths)
  end

  def clear
    @cache.delete(CACHE_KEY)
  end

  # Helpers
  
  def page_type_for_path(path)
    self.entries.keys.detect do |page_type|
      paths = self.entries.fetch(page_type)
      paths.include?(path)
    end
  end

  def root_page_type
    page_type_for_path('')
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