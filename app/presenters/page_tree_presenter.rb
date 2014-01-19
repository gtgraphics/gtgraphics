class PageTreePresenter < Presenter
  presents :pages

  def render
    level = parent_page.try(:depth) || 0
    capture_haml do
      options[:class] = "#{options[:class]} level-#{level}".strip
      haml_tag :ul, options.except(:parent) do
        render_item(parent_page_id, level)
      end
    end
  end

  private
  def parent_page
    options[:parent]
  end

  def parent_page_id
    parent_page.try(:id)
  end

  def pages_by_parents
    @pages_by_parents ||= pages.group_by(&:parent_id)
  end

  def render_item(parent_id = nil, level = 0)
    pages = Array(pages_by_parents[parent_id])
    pages.each do |page|
      css = "page #{page.state}"
      if page.has_descendants?
        css << ' with-descendants'
        css << ' open' if pages_by_parents[page.id]
      end
      haml_tag :li, id: "page_#{page.id}", class: css, data: { page_id: page.id } do
        if page.has_descendants?
          haml_concat link_to(page.title, '#', class: 'toggle-descendants')
        else
          haml_concat page.title
        end
        if pages_by_parents[page.id]
          haml_tag :ul, class: "level-#{level.next}" do
            render_item(page.id, level.next)
          end
        end
      end
    end
  end
end