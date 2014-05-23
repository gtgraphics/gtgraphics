class Admin::PagePresenter < Admin::ApplicationPresenter
  presents :page

  def embeddable_type
    super.constantize.model_name.human
  end

  def indexable
    h.yes_or_no(indexable?)
  end

  def menu_item
    h.yes_or_no(menu_item?)
  end

  def published
    h.yes_or_no(published?)
  end

  def translated_locales
    super.map do |locale|
      h.link_to I18n.translate(locale, scope: :languages), h.admin_page_editor_path(page, page_locale: locale)
    end.sort.join(', ').html_safe
  end
end