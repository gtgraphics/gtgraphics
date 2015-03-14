module Page::SocialLinkHelper
  def social_link_icon(social_link)
    image_path = attached_asset_path(social_link.provider,
                                     :thumbnail, from: :logo)
    content_tag :div, class: 'icon-menu-item' do
      link_to social_link.url, target: '_blank', class: 'icon-menu-link',
                               title: social_link.provider_name,
                               data: { toggle: 'tooltip', placement: 'top' } do
        concat image_tag(image_path, class: 'img-responsive',
                                     alt: social_link.provider_name)
        concat content_tag(:span, social_link.provider_name, class: 'sr-only')
      end
    end
  end

  def footer_social_network_link(user, provider_name, &block)
    @footer_social_link_icons ||= {}
    @footer_social_link_icons[user] ||= begin
      user.social_links.networks.includes(:provider)
      .each_with_object({}) do |network, networks|
        networks[network.provider_name] = network
      end
    end
    social_link = @footer_social_link_icons[user][provider_name]
    return nil if social_link.nil?
    link_to social_link.url, target: '_blank', title: provider_name,
                             class: 'icon-link',
                             data: { toggle: 'tooltip', placement: 'top' } do
      concat capture(&block)
      concat content_tag(:span, social_link.provider_name, class: 'sr-only')
    end
  end
end
