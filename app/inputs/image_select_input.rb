class ImageSelectInput < ResourceSelectInput
  def resource_name
    'images'
  end

  def formatter
    'ImageComboboxFormatter'
  end

  def paginated?
    true
  end

  def url
    template.admin_images_path(format: :json)
  end
end