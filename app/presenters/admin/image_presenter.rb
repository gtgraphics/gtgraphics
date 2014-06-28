class Admin::ImagePresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter
  
  presents :image

  def artist
    exif_data[:artist]
  end

  def author(linked = true)
    if image.author
      h.link_to_if linked, author_name, [:admin, image.author]
    else
      artist
    end
  end

  def dimensions
    original_dimensions = I18n.translate(:dimensions, width: original_width, height: original_height)
    if image.cropped?
      crop_dimensions = I18n.translate(:dimensions, width: width, height: height)
      "#{crop_dimensions} (#{original_dimensions})"
    else
      original_dimensions
    end
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

  def taken_at
    h.time_ago(image.taken_at) if image.taken_at
  end

  def to_liquid
    attributes.slice(*%w(title width height updated_at file_size)).merge(customization_options).merge(
      'author' => author,
      'format' => content_type
    )
  end
end