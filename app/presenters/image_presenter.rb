class ImagePresenter < ApplicationPresenter
  include FileAttachablePresenter

  presents :image

  def artist
    exif_data[:artist]
  end

  def author
    present super, with: Admin::UserPresenter if image.author
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
end