module UsersHelper
  def user_thumbnail_image_tag(user, options = {})
    scope = options.delete(:scope)
    options = options.reverse_merge(
      alt: user.name, width: options[:size], height: options[:size])
    if user.photo.present?
      image_tag attached_asset_path(current_user, :thumbnail, from: :photo),
                options
    else
      scope = "#{scope}/" if scope
      image_tag "#{scope}anonymous.png", options
    end
  end
end
