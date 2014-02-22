module PageSitemapHelper
  def page_sitemap_collection_for_select(pages = Page.with_translations)
    pages_by_parents = pages.group_by(&:parent_id)
    collection = []
    page_sitemap_collection_for_select_recursive(collection, pages_by_parents, nil, 0)
    collection
  end

  private
  def page_sitemap_collection_for_select_recursive(collection, pages_by_parents, parent_id = nil, level = 0)
    Array(pages_by_parents[parent_id]).each do |page|
      collection << [level.times.collect { "&nbsp;&nbsp;&nbsp;&nbsp;" }.join.html_safe + page.title, page.id, data: { url: page_path(page) }]
      page_sitemap_collection_for_select_recursive(collection, pages_by_parents, page.id, level.next)
    end
  end
end