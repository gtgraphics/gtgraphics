class Admin::PagePresenter < Admin::ApplicationPresenter
  presents :page

  def created_on
    I18n.localize(page.created_at.to_date)
  end

  def embeddable_type
    super.constantize.model_name.human
  end

  def hits_count
    hits_count = h.number_with_delimiter(super)
    I18n.translate('views.admin.pages.hits_since', count: hits_count, date: created_on)
  end

  def indexable
    h.yes_or_no(indexable?)
  end

  def menu_item
    h.yes_or_no(menu_item?)
  end

  def path
    h.content_tag :span, super, class: 'monospace'
  end

  def url
    url = h.page_url(page, locale: nil, translations: nil).sub(h.request.protocol, '')
    h.content_tag :span, url, class: 'monospace'
  end

  def published
    h.yes_or_no(published?)
  end

  def template
    h.link_to page.template.name, h.edit_admin_template_path(page.template)
  end

  def translated_locales
    available_locales = super.sort_by { |locale| I18n.translate(locale, scope: :languages) }
    h.capture do
      h.content_tag :ul, class: 'inline-flag-icons' do
        available_locales.each do |locale|
          link = h.link_to h.page_path(page, locale: locale, translations: nil), hreflang: locale do
            h.prepend_flag_icon locale, I18n.translate(locale, scope: :languages), fixed_width: true, size: 16
          end
          h.concat h.content_tag(:li, link)
        end
      end
    end
  end
end