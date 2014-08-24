class Admin::PageTree
  include Rails.application.routes.url_helpers
  include RouteHelper

  def initialize(pages, options = {})
    @pages_by_parents = pages.group_by(&:parent_id)
    @selected_page = options[:selected]
  end

  def to_json(options = {})
    parent_id = @pages_by_parents.keys.min unless @pages_by_parents.key?(nil)
    serialize_pages(parent_id).to_json
  end

  private
  def serialize_pages(parent_id = nil)
    pages = @pages_by_parents[parent_id]
    pages.collect do |page|
      page_hash = { id: page.id, label: page.title, load_on_demand: !page.leaf?,
                    root: page.root?, destroyable: page.destroyable?, published: page.published?,
                    type: page.embeddable_type.demodulize.camelize(:lower),
                    human_type: page.embeddable_class.model_name.human,
                    url: admin_page_path(page), move_url: move_admin_page_path(page) }
      page_hash[:active] = page == @selected_page if @selected_page
      page_hash[:children] = serialize_pages(page.id) if @pages_by_parents[page.id]
      page_hash
    end
  end

  def default_url_options(options = nil)
    { locale: I18n.locale, translations: Globalize.locale != I18n.locale ? Globalize.locale : nil }
  end
end