class ProjectSelectInput < ResourceSelectInput
  def resource_name
    'projects'
  end

  def formatter
    'ProjectComboboxFormatter'
  end

  def paginated?
    true
  end

  def url
    template.admin_projects_path(format: :json)
  end
end