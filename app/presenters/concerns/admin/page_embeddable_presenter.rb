module Admin::PageEmbeddablePresenter
  extend ActiveSupport::Concern

  def pages_count(linked = false)
    count = object.pages.count
    linked = false if count.zero?
    h.link_to_if linked, "#{count} #{Page.model_name.human(count: count)}", [:pages, :admin, object], remote: true
  end
end