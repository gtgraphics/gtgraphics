class Admin::ImagePresenter < Admin::ApplicationPresenter
  include AssetContainablePresenter
  
  presents :image

  def author
    if image.author
      h.link_to author_name, [:admin, image.author]
    else
      exif_data.artist
    end
  end

  def dimensions
    if image.cropped?
      "#{image.crop_dimensions} (#{image.dimensions})"
    else
      image.dimensions.to_s
    end
  end

  def taken_at
    h.time_ago(image.taken_at) if image.taken_at
  end

  def to_liquid
    attributes.slice(*%w(title width height updated_at)).merge(customization_options).merge(
      'author' => author,
      'file_name' => asset_file_name,
      'file_size' => asset_file_size,
      'format' => content_type
    )
  end
end