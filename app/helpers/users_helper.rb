module UsersHelper
  def user_info(user, options = {}, &block)
    options = options.reverse_merge(avatar_size: 32)

    content_tag :div, class: 'user-info' do
      concat gravatar_image_tag(user.email, class: 'user-avatar img-circle',
                                            alt: user.name,
                                            default: :mm,
                                            size: options[:avatar_size])
      concat content_tag(:div, user.name, class: 'user-name')
      concat capture(&block) if block_given?
    end
  end
end
