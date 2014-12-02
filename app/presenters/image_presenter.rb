class ImagePresenter < ApplicationPresenter
  include FileAttachablePresenter

  presents :image
  
  delegate_presented :author, with: 'Admin::UserPresenter'

  def artist
    exif_data[:artist]
  end

  def author_name(linked = true)
    author ? author.name : artist
  end

  def dimensions(include_originals = false)
    original_dimensions = I18n.translate(:dimensions, width: original_width, height: original_height)
    if image.cropped?
      crop_dimensions = I18n.translate(:dimensions, width: width, height: height)
      if include_originals
        "#{crop_dimensions} (#{original_dimensions})"
      else
        crop_dimensions
      end
    else
      original_dimensions
    end
  end

  def styles_count
    count = image.styles.count
    "#{count} #{Image::Style.model_name.human(count: count)}"
  end
  
  def taken_at
    h.time_ago(image.taken_at) if image.taken_at
  end

  def shop_links
    h.content_tag :ul, class: 'shop-providers' do
      Image.available_shop_providers.each do |name|
        if image.shop_urls[name].present?
          h.concat h.content_tag(:li, shop_link(name), class: 'shop-provider')
        end
      end
    end
  end

  def shop_link(name)
    url = image.shop_urls[name]
    human_name = I18n.translate(name, scope: 'views.page/image.shops', default: name.to_s.humanize)

    h.link_to url, target: '_blank' do
      h.concat h.shop_provider_icon(name)
      h.concat h.content_tag(:span, human_name, class: 'caption')
    end
  end

  Image.available_shop_providers.each do |name|
    class_eval <<-RUBY
      def #{name}_link
        self.shop_link(:#{name})
      end
    RUBY
  end
end