module UsersHelper
  def user_info(name, email, options = {})
    content_tag :div, class: 'user-info' do
      inner_html = content_tag(:div, class: 'pull-left', style: 'margin-right: 8px;') do
        mail_to(email) do
          gravatar_image_tag(email, class: 'thumbnail loader-small', size: 30, alt: name, style: 'width: 40px; height: 40px;')
        end
      end
      inner_html << content_tag(:div, mail_to(email, name))
      inner_html << content_tag(:div, email, class: 'text-muted visible-lg visible-md')
      inner_html
    end
  end
end