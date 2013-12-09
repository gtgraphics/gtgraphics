module UsersHelper
  def user_info(user)
    content_tag :span, user.full_name, class: 'user-info', data: { user_id: user.id, full_user_name: user.full_name }
  end
end