class Routing::Cms::RouteCache
  include Singleton

  CACHE_KEY = 'cms.routes'

  class << self
    delegate :entries, :matches?, :rebuild, :clear, to: :instance
    delegate :page_type_for_path, :root_page_type, to: :instance
  end

  def initialize
    @cache = ActiveSupport::Cache::MemoryStore.new
    # @cache = ActiveSupport::Cache::NullStore.new
  end

  def entries
    @cache.fetch(CACHE_KEY) { collect_paths }
  end

  def matches?(page_type, path = nil, &block)
    path = block || path || fail(ArgumentError, 'no path given')
    paths = entries[page_type]
    return false unless paths
    case path
    when Proc then paths.any?(&path)
    when Regexp then paths.any? { |item| item =~ path }
    else paths.include?(path)
    end
  end

  def rebuild
    @cache.write(CACHE_KEY, collect_paths)
  end

  def clear
    @cache.delete(CACHE_KEY)
  end

  # Helpers

  def page_type_for_path(path)
    entries.keys.detect do |page_type|
      entries.fetch(page_type).include?(path)
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
