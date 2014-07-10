class Admin::UserPresenter < Admin::ApplicationPresenter
  def gravatar(options = {})
    options = options.reverse_merge(default: :mm, class: 'img-responsive img-circle', size: 80, alt: name)
    h.gravatar_image_tag email, options
  end
end