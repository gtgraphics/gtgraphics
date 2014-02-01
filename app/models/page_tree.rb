class PageTree
  include Rails.application.routes.url_helpers
  include RouteHelper

  def initialize(pages)
    @pages_by_parents = pages.group_by(&:parent_id)
  end

  def to_json(options = {})
    parent_id = @pages_by_parents.keys.min unless @pages_by_parents.key?(nil)
    serialize_pages(parent_id).to_json
  end

  private
  def serialize_pages(parent_id = nil)
    pages = @pages_by_parents[parent_id]
    pages.collect do |page|
      page_hash = { id: page.id, label: page.title, load_on_demand: page.has_children?,
                    root: page.root?, destroyable: page.destroyable?,
                    url: admin_page_path(page, locale: I18n.locale),
                    move_url: move_admin_page_path(page, locale: I18n.locale) }
      page_hash.merge!(children: serialize_pages(page.id)) if @pages_by_parents[page.id]
      page_hash
    end
  end
end