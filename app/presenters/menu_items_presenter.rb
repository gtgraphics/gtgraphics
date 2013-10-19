class MenuItemsPresenter < Presenter
  presents :menu_items

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
        haml_tag :tbody do
          render_row
        end
      end
    end
  end

  private
  def menu_items_by_parents
    @menu_items_by_parents ||= menu_items.group_by(&:parent_id)
  end

  def render_row(parent_id = nil, level = 0)
    Array(menu_items_by_parents[parent_id]).each do |menu_item|
      haml_tag :tr, class: "level-#{level}", data: { level: level } do
        haml_tag 'td.checkbox-cell', check_box_tag(:menu_item_ids, menu_item.id, false, multiple: true) if checkboxes?
        haml_tag 'td.level-indented', link_to(menu_item.title, menu_item_target_path(menu_item))
        haml_tag 'td.actions', action_buttons_for(menu_item, size: :mini, except: :show)
      end
      render_row(menu_item.id, level.next)
    end
  end
end