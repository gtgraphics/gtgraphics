class Admin::ImagePresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter
  include Admin::TaggablePresenter
  include Admin::PageEmbeddablePresenter
  include Admin::Image::CustomizablePresenter

  self.action_buttons = [:show, :enlarge, :edit, :destroy]

  presents :image
  delegate_presented :author, with: 'Admin::UserPresenter'

  def artist
    exif_data[:artist]
  end

  def author_name(linked = true)
    if image.author
      h.link_to_if linked, image.author.name, [:admin, image.author]
    else
      artist
    end
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

  def dominant_colors
    h.capture do
      image.dominant_colors.to_hex.map do |color|
        h.concat h.content_tag(:div, nil, class: 'img-circle',
                                          style: "background-color: #{color};" \
                                                 ' width: 24px; height: 24px;')
      end
    end
  end

  def file_size(include_styles = false)
    h.capture do
      h.concat h.number_to_human_size(
        image.file_size, strip_insignificant_zeros: false, precision: 3
      )
      if include_styles && image.styles.any?
        total_size = image.file_size + image.styles.sum(:file_size)
        human_size = h.number_to_human_size(
          total_size, strip_insignificant_zeros: false, precision: 3
        )
        h.concat " (#{human_size})"
      end
    end
  end

  def pixels_count
    h.number_to_human(image.width * image.height) +
      " #{I18n.translate(:pixels)}"
  end

  def styles_count
    count = image.styles.count
    "#{count} #{Image::Style.model_name.human(count: count)}"
  end

  def summary
    content_type
  end

  def taken_at
    h.time_ago(image.taken_at) if image.taken_at
  end

  def thumbnail(options = {})
    width = height = options.delete(:size) { 300 }
    options = options.reverse_merge(class: 'img-circle', alt: image.title,
                                    width: width, height: height)
    h.image_tag image.asset.url(:thumbnail), options
  end

  def to_liquid
    attributes.slice(*%w(title width height updated_at file_size))
      .merge(customization_options).merge(
        'author' => author,
        'format' => content_type
      )
  end

  # Paths

  def enlarge_path
    h.attached_asset_path(image, :custom)
  end

  # Buttons

  def enlarge_button(_options = {})
    h.button_link_to_if readable?, enlarge_path,
                        target: '_blank', type: :action,
                        title: I18n.translate('helpers.links.enlarge'),
                        data: { toggle: 'tooltip', container: 'body' } do
      h.prepend_icon :expand, I18n.translate('helpers.links.enlarge'),
                     fixed_width: true, caption_html: { class: 'sr-only' }
    end
  end
end
