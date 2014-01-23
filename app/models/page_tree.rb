class PageTree
  include Rails.application.routes.url_helpers
  include RouteHelper

  def initialize(pages)
    @pages = pages
  end

  def to_json(options = {})
    Jbuilder.encode do |json|
      json.key_format! camelize: :lower
      json.array! @pages do |page|
        json.id page.id
        json.title page.title
        json.url admin_page_path(page, locale: I18n.locale)
        json.has_descendants page.has_descendants?
      end
    end
  end
end