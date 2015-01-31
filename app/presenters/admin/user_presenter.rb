class Admin::UserPresenter < Admin::ApplicationPresenter
  presents :user

  self.action_buttons -= [:show]

  def thumbnail(*args)
    options = args.extract_options!
    options = options.reverse_merge(
      width: options[:size],
      height: options[:size],
      class: 'img-circle'
    )
    linked = args.first
    content = h.user_thumbnail_image_tag(user, options)
    h.link_to_if linked, content, [:admin, user]
  end

  def name(linked = false)
    if user
      h.link_to_if linked, user.name, [:admin, user]
    else
      I18n.translate('views.admin.users.unknown')
    end
  end

  def last_activity
    return if last_activity_at.blank?
    h.capture do
      h.concat I18n.translate('views.admin.users.active_since')
      h.concat ' '
      h.concat h.time_ago(last_activity_at)
    end
  end

  def to_s
    name(false)
  end
end
