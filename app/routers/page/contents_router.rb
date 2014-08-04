class Page::ContentsRouter < Page::ApplicationRouter
  def declare
    super
    post :search, as: :search_page
  end
end