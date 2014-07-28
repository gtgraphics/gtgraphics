class Admin::ImagePresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter
  include Admin::Image::CustomizablePresenter

  self.action_buttons -= [:show]
  
  presents :image

  def artist
    exif_data[:artist]
  end

  def author
    present image.author, with: Admin::UserPresenter if image.author
  end

  def author_name(linked = true)
    if image.author
      h.link_to_if linked, image.author.name, [:admin, image.author]
    else
      artist
    end
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

  def dominant_colors
    h.capture do
      image.dominant_colors.to_hex.map do |color|
        h.concat h.content_tag(:div, nil, class: 'img-circle', style: "background-color: #{color}; width: 24px; height: 24px;")
      end
    end
  end

  def file_size
    total_size = image.file_size + image.styles.sum(:file_size)
    h.capture do
      h.concat h.number_to_human_size(image.file_size)
      if image.styles.any?
        h.concat ' ('
        h.concat h.number_to_human_size(total_size)
        h.concat ')'
      end
    end
  end

  def pixels_count
    h.number_to_human(image.width * image.height) + " #{I18n.translate(:pixels)}"
  end

  def preview_html
    h.capture do
      h.content_tag :div, class: 'dl-vertical' do
        h.concat h.content_tag(:div, dimensions)
        h.concat h.content_tag(:div, content_type)
        h.concat h.content_tag(:div, file_size)
        h.concat h.content_tag(:div, author(false))
      end
    end.to_str
  end

  def pages_count
    count = image.pages.count
    h.link_to "#{count} #{Page.model_name.human(count: count)}", [:pages, :admin, image], remote: true
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
    options = options.reverse_merge(class: 'img-circle', alt: image.title, width: width, height: height)
    h.image_tag image.asset.url(:thumbnail), options
  end

  def to_liquid
    attributes.slice(*%w(title width height updated_at file_size)).merge(customization_options).merge(
      'author' => author,
      'format' => content_type
    )
  end
end