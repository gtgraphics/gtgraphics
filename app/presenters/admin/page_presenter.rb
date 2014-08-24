class Admin::PagePresenter < Admin::ApplicationPresenter
  presents :page

  def author
    present super, with: Admin::UserPresenter 
  end

  def author_name(*args)
    author.name(*args)
  end

  def breadcrumbs
    h.content_tag :span, class: 'page-path' do
      pages = page.self_and_ancestors.to_a
      pages.each_with_index do |page, index|
        last_item = index == pages.count - 1
        path_segment = h.content_tag :span, class: ['path-segment', last_item ? 'slug' : nil].compact do
          if page.root?
            caption = h.content_tag :span, class: 'home', title: page.title, data: { toggle: 'tooltip' } do
              h.prepend_icon :home, page.title, fixed_width: true, caption_html: { class: 'sr-only' }
            end
          else
            caption = page.slug
          end
          h.link_to_unless last_item, caption, [:admin, page]
        end
        h.concat path_segment
        h.concat h.content_tag(:span, '/', class: 'path-separator text-muted') unless last_item
      end
    end
  end

  def created_on
    I18n.localize(page.created_at.to_date)
  end

  def embeddable_type
    page.embeddable_class.model_name.human
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

  def status
    caption = I18n.translate(page.published? ? 'published' : 'hidden', scope: 'page.states')
    label_style = page.published? ? 'success' : 'default'
    h.content_tag :span, caption, class: ['label', "label-#{label_style}"]
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

  def translations
    available_locales = I18n.available_locales.sort_by { |locale| I18n.translate(locale, scope: :languages) }
    h.content_tag :ul, class: 'list-inline translations' do
      available_locales.each do |locale|
        url = h.page_path(page, locale: locale, translations: nil)
        human_name = I18n.translate(locale, scope: :languages)
        link = h.link_to url, hreflang: locale, title: human_name, data: { no_turbolink: true, toggle: 'tooltip', container: 'body' } do
          h.prepend_flag_icon locale, human_name, fixed_width: true, size: 16, caption_html: { class: 'sr-only' }
        end
        h.concat h.content_tag(:li, link)
      end
    end
  end
end