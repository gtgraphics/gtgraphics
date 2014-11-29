class TagsInput < ResourceSelectInput
  def resource_name
    'tags'
  end

  def formatter
    'TagsComboboxFormatter'
  end

  def url
    template.admin_tags_path(format: :json)
  end

  def multiple?
    true
  end

  def paginated?
    true
  end

  def allow_non_existing?
    true
  end
end