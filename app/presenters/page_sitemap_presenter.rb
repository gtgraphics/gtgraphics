class PageSitemapPresenter < Presenter
  presents :pages

  def checkboxes?
    options.fetch(:checkboxes, false)
  end

  def render
    html_options = options.slice(:class, :id)
    html_options[:class] ||= ""
    html_options[:class] = " table-indented"
    html_options[:class].strip!

    capture_haml do
      haml_tag 'table.table', html_options do
        haml_tag :thead do
          render_header
        end
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

  def render_header
    haml_tag :tr do
      haml_tag :th, '' if checkboxes?
      haml_tag :th, Page.human_attribute_name(:title)
      haml_tag :th, Page.human_attribute_name(:embeddable_type)
      haml_tag :th, Page.human_attribute_name(:published)
      haml_tag :th, ''
    end
  end

  def render_row(parent_id = nil, level = 0)
    pages = Array(pages_by_parents[parent_id])
    pages.each_with_index do |page, index|
      haml_tag :tr, class: "level-#{level}", data: { level: level } do
        haml_tag 'td.checkbox-cell', check_box_tag(:page_ids, page.id, false, multiple: true) if checkboxes?
        haml_tag 'td.level-indented', link_to(page.title, page_path(page))
        haml_tag :td, page.embeddable_class.model_name.human
        haml_tag :td, link_to(yes_or_no(page.published?), [:toggle, :admin, page], method: :patch)
        haml_tag 'td.actions' do
          haml_tag '.btn-toolbar' do
            haml_tag '.btn-group' do
              haml_concat view_button_link_for(page, namespace: :admin, icon_only: true, size: :mini)
            end
            haml_tag '.btn-group' do
              haml_concat update_button_link_for(page, namespace: :admin, icon_only: true, size: :mini)
              haml_concat button_link_to_unless(index.zero?, icon(:chevron_up), [:move_up, :admin, page], method: :patch, size: :mini, title: translate('helpers.links.move_up', model: Page.model_name.human), data: { toggle: 'tooltip', placement: 'top', container: 'body' })
              haml_concat button_link_to_unless(index == pages.length - 1, icon(:chevron_down), [:move_down, :admin, page], method: :patch, size: :mini, title: translate('helpers.links.move_down', model: Page.model_name.human), data: { toggle: 'tooltip', placement: 'top', container: 'body' })
            end
            haml_tag '.btn-group' do
              haml_concat destroy_button_link_for(page, namespace: :admin, icon_only: true, size: :mini, type: :danger)
            end
          end
        end
      end
      render_row(page.id, level.next)
    end
  end
end