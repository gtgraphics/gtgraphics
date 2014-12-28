module UsersHelper
  def user_info(user, options = {}, &block)
    avatar_size = options.fetch(:avatar_size, 32)
    html_options = options.except(:avatar_size)
    html_options[:class] = ['user-info', html_options[:class]].compact

    content_tag :div, html_options do
      concat gravatar_image_tag(user.email, class: 'user-avatar img-circle',
                                            alt: user.name, default: :mm,
                                            size: avatar_size)
      concat content_tag(:div, user.name, class: 'user-name')
      concat capture(&block) if block_given?
    end
  end
end
