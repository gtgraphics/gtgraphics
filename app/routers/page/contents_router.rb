class Page::ContentsRouter < Page::ApplicationRouter
  def initialize
    super
    post :search, as: :search_page
  end
end