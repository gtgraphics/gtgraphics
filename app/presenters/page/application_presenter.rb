class Page::ApplicationPresenter < ApplicationPresenter
  delegate :page, to: :object
end