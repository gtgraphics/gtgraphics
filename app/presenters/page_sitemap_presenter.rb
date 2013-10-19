class PageSitemapPresenter < Presenter
  presents :pages

  def checkboxes?
    options.fetch(:checkboxes, false)
  end

  def render
    capture_haml do
      haml_tag 'table.table', options.slice(:class, :id) do
        haml_tag :tbody do
          render_row
        end
      end
    end
  end

  private
  def pages_by_parents
    @pages_by_parents ||= pages.group_by(&:parent_id)
  end

  def render_row(parent_id = nil, level = 0)
    Array(pages_by_parents[parent_id]).sort_by(&:title).each do |page|
      haml_tag :tr, class: "level-#{level}", data: { level: level } do
        haml_tag 'td.checkbox-cell', check_box_tag(:page_ids, page.id, false, multiple: true) if checkboxes?
        haml_tag 'td.level-indented', link_to(page.title, page)
        haml_tag 'td.actions', action_buttons_for(page, size: :mini)
      end
      render_row(page.id, level.next)
    end
  end
end