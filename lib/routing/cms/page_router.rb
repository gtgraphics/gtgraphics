class Routing::Cms::PageRouter
  include Singleton

  class << self
    delegate :insert, to: :instance
  end

  def insert(map)
    # do not insert any routes if there are pending migrations;
    # not using this line may prevent the console, server or
    # even tasks from being executed
    return if ActiveRecord::Migrator.needs_migration?

    ::Page::EMBEDDABLE_TYPES.each do |page_type|
      router = "#{page_type.pluralize}Router".constantize.new
      router.insert(map)
    end
  end
end