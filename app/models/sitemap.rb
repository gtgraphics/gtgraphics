class Sitemap
  PAGE_SIZE = 50000

  class << self
    def all
      1.upto(count).collect { |page| new(page) }
    end

    def count
      pages.page(1).per(PAGE_SIZE).total_pages
    end

    def page(page)
      new(page)
    end

    def pages
      Page.published.indexable
    end
  end

  attr_reader :page

  def initialize(page)
    @page = page
  end

  def pages
    self.class.pages.page(@page).per(PAGE_SIZE)
  end

  def updated_at
    pages.maximum(:updated_at).in_time_zone
  end
end