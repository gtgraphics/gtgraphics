class Admin::UserPresenter < Admin::ApplicationPresenter
  presents :user
  
  def gravatar(options = {})
    options = options.reverse_merge(default: :mm, class: 'img-responsive img-circle', size: 80, alt: full_name)
    h.gravatar_image_tag email, options
  end

  def name(linked = false)
    h.link_to_if linked, user.name, [:admin, user]
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
end