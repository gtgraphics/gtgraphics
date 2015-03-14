class Admin::User::SocialLinkPresenter < Admin::ApplicationPresenter
  include Admin::MovableResourcePresenter

  presents :social_link
  delegate :user, to: :social_link

  self.action_buttons = [:edit, :move_up, :move_down, :destroy]

  delegate_presented :provider, scope: :admin
  delegate :thumbnail, to: :provider

  def name(linked = false)
    h.link_to_if linked, social_link.provider.name,
                 h.edit_admin_user_social_link_path(user, social_link)
  end

  def shop
    h.yes_or_no social_link.shop?
  end

  def compact_url
    return placeholder unless social_link.url.present?
    h.link_to social_link.url, target: '_blank' do
      social_link.url.gsub(%r{\A(http|https)\://}, '').truncate(50)
    end
  end

  def to_s
    name(false)
  end

  def move_up_path
    h.move_up_admin_user_social_link_path(user, social_link)
  end

  def move_down_path
    h.move_down_admin_user_social_link_path(user, social_link)
  end

  def destroy_path
    h.admin_user_social_link_path(user, social_link)
  end

  def edit_path
    h.edit_admin_user_social_link_path(user, social_link)
  end
end
