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
      height: options[:size],
      class: 'img-circle'
    )
    linked = args.first && about_page?
    content = h.user_thumbnail_image_tag(user, options)
    h.link_to_if linked, content, path
  end
end
