class Admin::UserPresenter < Admin::ApplicationPresenter
  presents :user

  self.action_buttons -= [:show]

  def gravatar(*args)
    options = args.extract_options!.reverse_merge(class: 'img-responsive img-circle', size: 80, alt: self.name(false))
    linked = args.first || false
    if user
      default_url = Rails.env.development? ? :mm : h.asset_url('admin/anonymous.png')
      image_tag = h.gravatar_image_tag user.email, options.reverse_merge(default: default_url)
      h.link_to_if linked, image_tag, [:admin, user]
    else
      size = options.delete(:size)
      h.image_tag 'admin/anonymous.png', options.reverse_merge(width: size, height: size)
    end
  end

  def name(linked = false)
    if user
      h.link_to_if linked, user.name, [:admin, user]
    else
      I18n.translate('views.admin.users.unknown')
    end
  end

  def last_activity
    if last_activity_at.present?
      h.capture do
        h.concat I18n.translate('views.admin.users.active_since')
        h.concat ' '
        h.concat h.time_ago(last_activity_at)
      end
    end
  end

  def to_s
    name(false)
  end
end