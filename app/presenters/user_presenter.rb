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

  def gravatar(*args)
    options = args.extract_options!.reverse_merge(
      class: 'img-responsive img-circle',
      size: 75,
      alt: name
    )
    image_tag = h.gravatar_image_tag email, options.reverse_merge(default: :mm)
    h.link_to_if about_page? && args.first, image_tag, path
  end
end
