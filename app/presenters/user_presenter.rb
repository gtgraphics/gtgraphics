class UserPresenter < ApplicationPresenter
  presents :user

  def name(linked = false)
    h.link_to_if about_page? && linked, user.name, path
  end

  def path
    @path ||= begin
      page = Page.where(parent_id: Page.where(path: 'about'))
             .find_by(title: user.name)
      h.page_path(page) if page
    end
  end

  def about_page?
    path.present?
  end

  def thumbnail(*args)
    options = args.extract_options!
    options = options.reverse_merge(
      width: options[:size],
      height: options[:size]
    )
    linked = args.first && about_page?
    content = h.user_thumbnail_image_tag(user, options)
    h.link_to_if linked, content, path
  end

  def info
    details = h.capture do
      h.concat thumbnail(class: 'author-picture')
      h.concat h.content_tag(:div, name, class: 'author-name')
    end
    h.content_tag :div, details, class: 'author-info' unless about_page?
    h.link_to details, path, class: 'author-info'
  end

  def info_icon
    pic = thumbnail(class: 'author-picture img-emerging')
    h.content_tag :div, pic, class: 'author-info' unless about_page?
    h.link_to pic, path, class: 'author-info', title: name,
                         data: { toggle: 'tooltip', placement: 'top',
                                 container: 'body' }
  end
end
