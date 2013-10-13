class SitemapPresenter < Presenter
  presents :pages

  def render
    content_tag :table, class: 'table' do
    end
  end
end