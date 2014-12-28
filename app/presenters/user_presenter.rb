class UserPresenter < ApplicationPresenter
  presents :user

  def name(linked = false)
    h.link_to_if linked, user.name, h.about_author_path(user)
  end

  def gravatar(*args)
    options = args.extract_options!.reverse_merge(
      class: 'img-responsive img-circle',
      size: 75,
      alt: name
    )
    image_tag = h.gravatar_image_tag email, options.reverse_merge(default: :mm)
    h.link_to_if args.first, image_tag, h.about_author_path(user)
  end
end
