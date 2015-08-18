module Social
  module PinterestHelper
    def pinterest_share_button(url, image_url, options = {})
      options = options.reverse_merge(size: 20, annotation: false, color: :red)

      annotation = options[:annotation]
      annotation = 'beside' if annotation.nil?
      annotation = 'none' if annotation == false

      query_params = { url: url, media: image_url,
                       description: options[:description] }

      link_to "//www.pinterest.com/pin/create/button/?#{query_params.to_query}",
              data: { pin_do: 'buttonPin', pin_config: annotation, pin_color: options[:color] } do
        image_tag "//assets.pinterest.com/images/pidgets/pinit_fg_en_rect_red_#{options[:size]}.png",
                  alt: 'Pinterest'
      end
    end
  end
end
