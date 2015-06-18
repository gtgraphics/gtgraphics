module Page::MenuHelper
  def menu_items(parent_page = nil)
    pages = parent_page.nil? ? Page.primary : parent_page.children
    pages.published.menu_items.accessible_by(current_ability)
      .with_translations_for_current_locale
  end

  def primary_menu_items
    @primary_menu_items ||= menu_items
  end

  def secondary_menu_items
    @secondary_menu_items ||= begin
      page = @page.self_and_ancestors.primary.first
      return Page.none if page.nil?
      menu_items(page)
    end
  end

  def footer_menu_items
    @footer_menu_items ||= Page.published.primary
                           .accessible_by(current_ability).without(menu_items)
  end
end
