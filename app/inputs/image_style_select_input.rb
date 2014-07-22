class ImageStyleSelectInput < ResourceSelectInput
  def resource_name
    'imageStyles'
  end

  def formatter
    'ImageStyleComboboxFormatter'
  end

  def paginated?
    true
  end

  def url
    nil
  end
end