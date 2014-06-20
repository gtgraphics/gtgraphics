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
    super.map { |locale| I18n.translate(locale, scope: :languages) }.sort.join(', ').html_safe
  end
end