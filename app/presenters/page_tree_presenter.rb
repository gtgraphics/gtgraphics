class PageTreePresenter < Presenter
  presents :pages

  def render
    level = parent_page.try(:depth).try(:next) || 0
    capture_haml do
      options[:class] = "#{options[:class]} level-#{level}".strip
      haml_tag :ul, options.except(:parent) do
        render_item(parent_page_id, level)
      end
    end
  end

  private
  def active_page
    options[:active]
  end
  
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
      children_loaded = !!pages_by_parents[page.id]
      css = "page page-#{page.state}"
      css << ' active' if page == active_page
      if page.has_descendants?
        css << ' with-descendants'
        css << ' open' if children_loaded
      end
      haml_tag :li, id: "page_#{page.id}", class: css, data: { page_id: page.id } do
        haml_tag 'span.node' do
          haml_tag 'span.node-icon' do
            haml_concat button_tag(caret(children_loaded ? :down : :right), type: 'button', class: 'toggle-children') if page.has_descendants?
          end
          haml_tag 'span.node-caption' do
            haml_concat link_to(page.title, [:admin, page], class: 'open-page')
          end
        end
        if children_loaded
          haml_tag :ul, class: "level-#{level.next}" do
            render_item(page.id, level.next)
          end
        end
      end
    end
  end
end