class PageTreePresenterTable < Presenter
  presents :pages

  def checkboxes?
    options.fetch(:checkboxes, false)
  end

  def render
    html_options = options.slice(:class, :id)
    html_options[:class] ||= ''
    html_options[:class] << ' table-indented'
    html_options[:class].strip!

    capture_haml do
      haml_tag 'table.table.table-hover', html_options do
        haml_tag :thead do
          render_header
        end
        haml_tag :tbody do
          render_row
        end
      end
    end
  end

  def render_row(parent_id = nil, level = 0)
    pages = Array(pages_by_parents[parent_id])
    pages.each_with_index do |page, index|
      css = "page level-#{level}"
      if page.has_descendants?
        css << ' with-descendants'
        css << ' opened' if pages_by_parents[page.id]
      end
      haml_tag :tr, id: "page_#{page.id}", class: css, data: { page_id: page.id, parent_page_id: parent_id, page_level: level } do
        haml_tag 'td.checkbox-cell', check_box_tag(:page_ids, page.id, false, multiple: true)
        haml_tag 'td.level-indented' do
          if page.has_descendants?
            haml_concat link_to(page.title, '#', class: 'toggle-descendants')
          else
            haml_concat page.title
          end
        end
        haml_tag :td, page.embeddable_class.model_name.human
        haml_tag 'td.hidden-xs', page.state_name
        haml_tag 'td.actions' do
          haml_tag '.btn-toolbar' do
            haml_tag '.btn-group' do
              haml_concat view_button_link_for(page, namespace: :admin, icon_only: true, size: :mini)
            end
            haml_tag '.btn-group' do
              haml_concat update_button_link_for(page, namespace: :admin, icon_only: true, size: :mini)
              if page.destroyable?
                haml_concat button_link_to_unless(index.zero?, icon(:chevron, direction: :up), [:move_up, :admin, page], method: :patch, size: :mini, title: translate('helpers.links.move_up', model: Page.model_name.human), data: { toggle: 'tooltip', placement: 'top', container: 'body' })
                haml_concat button_link_to_unless(index == pages.length - 1, icon(:chevron, direction: :down), [:move_down, :admin, page], method: :patch, size: :mini, title: translate('helpers.links.move_down', model: Page.model_name.human), data: { toggle: 'tooltip', placement: 'top', container: 'body' })
              end
            end
            if page.destroyable?
              haml_tag '.btn-group' do
                haml_concat destroy_button_link_for(page, namespace: :admin, icon_only: true, size: :mini, type: :danger)
              end
            end
          end
        end
      end
      render_row(page.id, level.next)
    end
  end

  private
  def pages_by_parents
    @pages_by_parents ||= pages.where(depth: 0..2).group_by(&:parent_id)
  end

  def render_header
    haml_tag :tr do
      haml_tag :th, ''
      haml_tag 'th.level-indented', Page.human_attribute_name(:title)
      haml_tag :th, Page.human_attribute_name(:embeddable_type)
      haml_tag 'th.hidden-xs', Page.human_attribute_name(:state)
      haml_tag :th, ''
    end
  end
end