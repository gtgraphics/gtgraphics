class Page::ApplicationPresenter < ::ApplicationPresenter
  def page
    present object.page
  end
end
