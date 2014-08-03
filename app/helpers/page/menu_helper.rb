module Page::MenuHelper
  def menu_items
    Page.primary.published.menu_items.accessible_by(current_ability).with_translations_for_current_locale
  end
end