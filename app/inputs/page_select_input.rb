class PageSelectInput < ResourceSelectInput
  def resource_name
    'pages'
  end

  def formatter
    'PageComboboxFormatter'
  end

  def url
    template.admin_pages_path(format: :json)
  end
end