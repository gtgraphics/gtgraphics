class ImagePresenter < ApplicationPresenter
  include FileAttachablePresenter

  presents :image

  delegate_presented :author

  def artist
    exif_data[:artist]
  end

  def author_name(_linked = true)
    author ? author.name : artist
  end

  def description
    super.try(:html_safe) if h.html_present?(super)
  end

  def dimensions(include_originals = false)
    original_dimensions = I18n.translate(:dimensions, width: original_width,
                                                      height: original_height)
    return original_dimensions unless image.cropped?
    crop_dimensions = I18n.translate(:dimensions, width: width, height: height)
    if include_originals
      "#{crop_dimensions} (#{original_dimensions})"
    else
      crop_dimensions
    end
  end

  def styles
    super.map { |style| present(style) }
  end

  def styles_count
    count = image.styles.count
    "#{count} #{Image::Style.model_name.human(count: count)}"
  end

  def taken_at
    h.time_ago(image.try(:taken_at) || image.created_at)
  end

  def f_number
    h.number_with_delimiter super
  end

  def iso_value
    h.number_with_delimiter super
  end

  def exposure_time
    return nil if image.exposure_time.blank?
    if image.exposure_time.is_a?(Rational)
      value = image.exposure_time.to_s
      unit = I18n.translate('helpers.units.second')
    else
      value = h.number_with_delimiter image.exposure_time
      unit = I18n.translate(image.exposure_time == 1 ? :second : :seconds,
                            scope: 'helpers.units')
    end
    "#{value} #{unit}"
  end

  def focal_length
    return nil if image.focal_length.blank?
    value, unit = image.focal_length.split(' ', 2)
    value = h.number_with_delimiter(value.to_f)
    "#{value} #{unit}"
  end

  def shop_links(include_buy_request = true)
    shop_providers = Image.available_shop_providers.dup
    shop_providers.unshift('gtgraphics') if include_buy_request
    h.capture do
      shop_providers.each do |name|
        if shop_url(name).present?
          h.concat h.content_tag(:li, shop_link(name), class: 'shop-provider')
        end
      end
    end
  end

  def shop_url(name)
    if name.to_s == 'gtgraphics'
      h.buy_image_path(template.page.path)
    else
      image.shop_urls[name]
    end
  end

  def shop_urls
    super.reject { |_name, value| value.nil? }
  end

  def shop_link(name)
    human_name = I18n.translate(name, scope: 'views.page/image.shops',
                                      default: name.to_s.humanize)
    target = (name.to_s != 'gtgraphics') ? '_blank' : nil
    h.link_to shop_url(name), target: target do
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
