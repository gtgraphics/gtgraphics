class PageSitemapPresenter < Presenter
  presents :pages

  def render
    capture_haml do
      haml_tag 'table.table.table-striped', id: 'page_sitemap' do
        haml_tag :thead do
          haml_tag :tr do
            haml_tag :th, Page.human_attribute_name(:name)
          end
        end
        haml_tag :tbody do
          render_row(nil, 0)
        end
      end
    end
  end

  private
  def pages_by_parents
    @pages_by_parents ||= pages.group_by(&:parent_id)
  end

  def render_row(parent_id, level)
    Array(pages_by_parents[parent_id]).each do |page|
      haml_tag :tr, class: "level-#{level}" do
        haml_tag 'td.level-indented', link_to(page.title, page)
        haml_tag 'td.actions', action_buttons_for(page, size: :mini)
      end
      render_row(page.id, level.next)
    end
  end
end