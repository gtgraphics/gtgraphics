module ThumbnailHelper
  def thumbnail(image_url, *args, &block)
    options = args.extract_options!
    image_link = args.first

    link_options = options.delete(:link_html) { Hash.new }

    container_options = options.delete(:container_html) { Hash.new }
    container_options[:class] ||= ''
    container_options[:class] << ' thumbnail'
    container_options[:class].strip!

    options[:class] ||= ''
    options[:class] << ' img-responsive'
    options[:class].strip!

    content_tag :div, container_options do
      inner_html = String.new.html_safe
      if image_link
        inner_html << link_to(image_link, link_options) do
          image_tag(image_url, options)
        end
      else
        inner_html << image_tag(image_url, options)
      end
      inner_html << content_tag(:div, class: 'caption', &block) if block_given?
      inner_html
    end
  end
end