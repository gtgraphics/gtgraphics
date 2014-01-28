class PageListPresenter < Presenter
  presents :pages

  def render
    capture_haml do
      haml_tag :ul, class: "level-#{min_depth}" do
        root_parent_ids.each do |parent_id|
          render_item(parent_id, min_depth)
        end
      end
    end
  end

  private
  def root_parent_ids
    @root_parent_ids ||= pages.select { |page| page.depth == min_depth }.collect(&:parent_id).uniq
  end

  def min_depth
    @min_depth ||= pages.collect(&:depth).min
  end

  def pages_by_parents
    @pages_by_parents ||= pages.group_by(&:parent_id)
  end

  def render_item(parent_page_id, level = 0)
    pages_by_parents[parent_page_id].each do |page|
      haml_tag :li do
        haml_tag :span, link_to(page.title, page), class: 'page-title'
        if pages_by_parents.key?(page.id)
          haml_tag :ul, class: "level-#{level}" do
            render_item(page.id, level.next)
          end
        end
      end
    end
  end
end